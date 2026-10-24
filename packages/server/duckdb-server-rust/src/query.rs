use anyhow::Result;

use crate::interfaces::{AppError, AppState, Command, ProtocolError, QueryParams, QueryResponse};

pub async fn handle(state: &AppState, params: QueryParams) -> Result<QueryResponse, AppError> {
    handle_request(state, params, false).await
}

pub(crate) async fn handle_request(
    state: &AppState,
    params: QueryParams,
    get: bool,
) -> Result<QueryResponse, AppError> {
    let command = params.query_type.ok_or_else(|| {
        ProtocolError::field("Missing required field: type", "missing_field", "type")
    })?;
    let sql = params
        .sql
        .as_deref()
        .filter(|s| !s.trim().is_empty())
        .ok_or_else(|| {
            ProtocolError::field("Missing or invalid field: sql", "missing_field", "sql")
        })?;
    match command {
        Command::Arrow => {
            state.db.validate(sql, get).await?;
            let buffer = if get {
                state.db.get_arrow_readonly(sql).await?
            } else {
                state.db.get_arrow(sql).await?
            };
            Ok(QueryResponse::Arrow(buffer))
        }
        Command::Exec => {
            state.db.execute(sql).await?;
            Ok(QueryResponse::Empty)
        }
        Command::Preagg => {
            state.db.validate(sql, true).await?;
            Ok(QueryResponse::Preagg(state.db.preaggregate(sql).await?))
        }
    }
}
