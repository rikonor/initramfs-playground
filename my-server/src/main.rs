use anyhow::{Context, Error};
use axum::{routing::get, Router};

#[tokio::main]
async fn main() -> Result<(), Error> {
    let app = Router::new().route("/", get(handler));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .context("failed to listen to address")?;

    println!("listening on {}", listener.local_addr().unwrap());

    axum::serve(listener, app)
        .await
        .context("failed to serve")?;

    Ok(())
}

async fn handler() -> &'static str {
    "Hello"
}
