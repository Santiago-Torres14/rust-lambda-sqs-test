use lambda_runtime::{LambdaEvent, service_fn, Error};
use aws_lambda_events::event::sqs::SqsEventObj;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Deserialize, Serialize)]
struct Data {
    id: String,
    text: String
}


async fn function_handler(event: LambdaEvent<SqsEventObj<Data>>) -> Result<(), Error> {
    let data = &event.payload.records[0].body;
    println!("{data:?}");
    Ok(())
}

#[tokio::main]
async fn main() -> Result<(), Error>{
    lambda_runtime::run(service_fn(function_handler)).await
}
