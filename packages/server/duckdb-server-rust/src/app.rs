use std::{collections::HashMap, sync::Arc, time::Duration};

use anyhow::Result;
use axum::{
    extract::{rejection::JsonRejection, DefaultBodyLimit, Query, State},
    http::{header, HeaderValue, Method, StatusCode},
    response::{IntoResponse, Response},
    routing::get,
    Json, Router,
};
use serde_json::{value::RawValue, Map, Value};
use tower_http::{
    compression::CompressionLayer,
    cors::{AllowHeaders, Any, CorsLayer},
    trace::TraceLayer,
};

use crate::{
    db::ConnectionPool,
    interfaces::{AppError, AppState, ProtocolError, QueryParams, QueryResponse},
    query,
};

pub const DEFAULT_DB_PATH: &str = ":memory:";
pub const DEFAULT_CONNECTION_POOL_SIZE: u32 = 10;

async fn handle_get(
    State(state): State<Arc<AppState>>,
    Query(params): Query<HashMap<String, String>>,
) -> Result<QueryResponse, AppError> {
    let params = QueryParams::decode(serde_json::to_value(params)?, true)?;
    query::handle_request(&state, params, true).await
}

async fn handle_post(
    State(state): State<Arc<AppState>>,
    body: Result<Json<HashMap<String, Box<RawValue>>>, JsonRejection>,
) -> Result<QueryResponse, AppError> {
    let Json(body) = body.map_err(|error| {
        let mut protocol = ProtocolError::new(
            error.body_text(),
            match error.status() {
                StatusCode::UNSUPPORTED_MEDIA_TYPE => "unsupported_media_type",
                StatusCode::PAYLOAD_TOO_LARGE => "payload_too_large",
                _ => "malformed_json",
            },
        );
        protocol.status = match error.status() {
            StatusCode::UNSUPPORTED_MEDIA_TYPE => StatusCode::UNSUPPORTED_MEDIA_TYPE,
            StatusCode::PAYLOAD_TOO_LARGE => StatusCode::PAYLOAD_TOO_LARGE,
            _ => StatusCode::BAD_REQUEST,
        };
        protocol
    })?;
    let mut fields = Map::new();
    for field in ["type", "sql"] {
        if let Some(raw) = body.get(field) {
            let value = serde_json::from_str::<String>(raw.get())
                .map(Value::String)
                .unwrap_or(Value::Null);
            fields.insert(field.to_owned(), value);
        }
    }
    query::handle(&state, QueryParams::decode(Value::Object(fields), false)?).await
}

async fn method_not_allowed() -> Response {
    let mut error = ProtocolError::new("Unsupported HTTP method", "method_not_allowed");
    error.status = StatusCode::METHOD_NOT_ALLOWED;
    AppError::Protocol(error).into_response()
}

async fn options() -> Response {
    let mut response = StatusCode::OK.into_response();
    response
        .headers_mut()
        .insert(header::CACHE_CONTROL, HeaderValue::from_static("no-store"));
    response
}

pub fn app(db_path: Option<&str>, connection_pool_size: Option<u32>) -> Result<Router> {
    let db = ConnectionPool::new(
        db_path.unwrap_or(DEFAULT_DB_PATH),
        connection_pool_size.unwrap_or(DEFAULT_CONNECTION_POOL_SIZE),
    )?;
    let state = Arc::new(AppState { db: Box::new(db) });
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods([Method::OPTIONS, Method::POST, Method::GET])
        .allow_headers(AllowHeaders::mirror_request())
        .max_age(Duration::from_secs(86_400));
    Ok(Router::new()
        .route(
            "/",
            get(handle_get)
                .post(handle_post)
                .options(options)
                .head(method_not_allowed)
                .fallback(method_not_allowed),
        )
        .with_state(state)
        .layer(DefaultBodyLimit::max(16 * 1024 * 1024))
        .layer(cors)
        .layer(axum::middleware::map_response(
            |mut response: Response| async move {
                response
                    .headers_mut()
                    .insert(header::CACHE_CONTROL, HeaderValue::from_static("no-store"));
                response
            },
        ))
        .layer(CompressionLayer::new())
        .layer(TraceLayer::new_for_http()))
}
