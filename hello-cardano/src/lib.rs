use serde_json::{from_str, json, to_string_pretty};

wit_bindgen::generate!("hermes");

struct Host;
export_hermes!(Host);

impl Hermes for Host {
    fn on_new_cardano(block: CardanoBlock) {
        let prime = primes::is_prime(block.slot);

        let hash_of_first_bytes = match block.raw_bytes.len() {
            0..=9 => vec![], // empty vec if the block is too small
            _ => host::blake_hash(&block.raw_bytes[0..10]),
        };

        let payload = json!({
            "slot": block.slot,
            "hash": block.hash,
            "hash_of_first_bytes": hash_of_first_bytes,
            "is_prime": prime,
        });

        let json_string = to_string_pretty(&payload).unwrap();

        host::publish(&json_string);
    }

    fn on_new_ethereum(rpc: wit_bindgen::rt::string::String) {
        #[derive(serde::Deserialize)]
        struct JsonRpc<'a> {
            id: u64,
            jsonrpc: &'a str,
        }

        let JsonRpc { id, jsonrpc } = from_str(&rpc).unwrap();

        let prime = primes::is_prime(id);

        let payload = json!({
            "id": id,
            "version": jsonrpc,
            "is_prime": prime,
        });

        let tweet = format!("look at this cool new eth RPC event: {payload}");

        host::tweet(&tweet);
    }
}
