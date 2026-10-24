use std::fmt;

use axum::{
    body::Bytes,
    http::{header, StatusCode},
    response::{IntoResponse, Response},
    Json,
};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

use crate::db::Database;

pub struct AppState {
    pub db: Box<dyn Database>,
}

#[derive(Deserialize, Serialize, Debug, Clone)]
#[serde(rename_all = "kebab-case")]
pub enum Command {
    Arrow,
    Exec,
    Preagg,
}

#[derive(Deserialize, Serialize, Debug, Default)]
pub struct QueryParams {
    #[serde(rename = "type")]
    pub query_type: Option<Command>,
    pub sql: Option<String>,
    pub name: Option<String>,
}

impl QueryParams {
    pub fn decode(value: Value, get: bool) -> Result<Self, ProtocolError> {
        let object = value
            .as_object()
            .ok_or_else(|| ProtocolError::new("Expected a JSON object", "malformed_json"))?;
        for field in ["type", "sql"] {
            let value = object.get(field).ok_or_else(|| {
                ProtocolError::field("Missing required field", "missing_field", field)
            })?;
            if value.as_str().is_none_or(|v| v.trim().is_empty()) {
                return Err(ProtocolError::field(
                    "Invalid field",
                    "invalid_field",
                    field,
                ));
            }
        }
        let typ = object["type"].as_str().unwrap_or_default();
        let command = match typ {
            "arrow" => Command::Arrow,
            "exec" if !get => Command::Exec,
            "preagg" if !get => Command::Preagg,
            _ => {
                return Err(ProtocolError::field(
                    "Invalid command type",
                    "invalid_field",
                    "type",
                ))
            }
        };
        Ok(Self {
            query_type: Some(command),
            sql: object["sql"].as_str().map(str::to_owned),
            name: None,
        })
    }
}

pub enum QueryResponse {
    Arrow(Vec<u8>),
    Preagg(Value),
    Empty,
}

impl IntoResponse for QueryResponse {
    fn into_response(self) -> Response {
        let mut response = match self {
            Self::Arrow(bytes) => (
                StatusCode::OK,
                [(header::CONTENT_TYPE, "application/vnd.apache.arrow.stream")],
                Bytes::from(bytes),
            )
                .into_response(),
            Self::Preagg(result) => Json(result).into_response(),
            Self::Empty => StatusCode::OK.into_response(),
        };
        response.headers_mut().insert(
            header::CACHE_CONTROL,
            header::HeaderValue::from_static("no-store"),
        );
        response
    }
}

#[derive(Debug, Clone, Serialize)]
pub struct ProtocolError {
    pub error: String,
    pub code: &'static str,
    pub reason: &'static str,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub field: Option<&'static str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub reference: Option<Value>,
    #[serde(skip)]
    pub status: StatusCode,
}

impl ProtocolError {
    pub fn new(message: impl Into<String>, reason: &'static str) -> Self {
        Self {
            error: message.into(),
            code: "bad_request",
            reason,
            field: None,
            reference: None,
            status: StatusCode::BAD_REQUEST,
        }
    }
    pub fn field(message: impl Into<String>, reason: &'static str, field: &'static str) -> Self {
        Self {
            field: Some(field),
            ..Self::new(message, reason)
        }
    }
}

impl fmt::Display for ProtocolError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str(&self.error)
    }
}
impl std::error::Error for ProtocolError {}

#[derive(Debug)]
pub enum AppError {
    Error(anyhow::Error),
    Protocol(ProtocolError),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let error = match self {
            Self::Protocol(error) => error,
            Self::Error(error) => {
                if let Some(protocol) = error.downcast_ref::<ProtocolError>() {
                    protocol.clone()
                } else {
                    let message = error.to_string();
                    if message.starts_with("Parser Error:") {
                        ProtocolError::new(message, "sql_parse_error")
                    } else if message.starts_with("TransactionContext Error:")
                        && message.contains("read-only mode")
                    {
                        ProtocolError::new(message, "not_read_only")
                    } else if message.starts_with("Out of Memory Error") {
                        ProtocolError {
                            error: message,
                            code: "resource_exhausted",
                            reason: "resource_limit_exceeded",
                            field: None,
                            reference: None,
                            status: StatusCode::TOO_MANY_REQUESTS,
                        }
                    } else {
                        ProtocolError {
                            error: message,
                            code: "internal_error",
                            reason: "execution_failed",
                            field: None,
                            reference: None,
                            status: StatusCode::INTERNAL_SERVER_ERROR,
                        }
                    }
                }
            }
        };
        let status = error.status;
        let mut response = (status, Json(json!(error))).into_response();
        response.headers_mut().insert(
            header::CACHE_CONTROL,
            header::HeaderValue::from_static("no-store"),
        );
        if status == StatusCode::METHOD_NOT_ALLOWED {
            response.headers_mut().insert(
                header::ALLOW,
                header::HeaderValue::from_static("GET, POST, OPTIONS"),
            );
        }
        response
    }
}

impl<E> From<E> for AppError
where
    E: Into<anyhow::Error>,
{
    fn from(err: E) -> Self {
        Self::Error(err.into())
    }
}
