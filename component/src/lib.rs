use serde_json::{json, to_string};

wit_bindgen::generate!("hermes");

struct Host;
export_hermes!(Host);

impl Hermes for Host {
    fn on_new_cardano(block: CardanoBlock) {
        let prime = primes::is_prime(block.slot);

        let hash = hex::encode(&block.hash);

        let payload = json!({
            "hash": hash,
            "slot": block.slot,
            "slot_is_prime": prime,
        });

        let json_string = to_string(&payload).unwrap();

        publish(&json_string);
    }

    fn on_new_ethereum(rpc: wit_bindgen::rt::string::String) {
        let len = rpc.as_bytes().len();
        let head = rpc.chars().take(20).collect::<String>();

        let msg = format!(
            "look at this cool new eth RPC event - it has {len} bytes and starts with {head}"
        );

        tweet(&msg);
    }
}
