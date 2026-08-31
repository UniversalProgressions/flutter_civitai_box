use std::fs::File;
use std::io::Read;

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

/// Compute a BLAKE3 hash of a file by streaming it in chunks.
///
/// The file is read in 1 MiB blocks and fed incrementally into the hasher, so
/// memory usage stays constant regardless of file size. Runs on the
/// flutter_rust_bridge thread pool, so it does not block the UI.
///
/// Returns the 64-char lowercase hex digest.
#[flutter_rust_bridge::frb]
pub async fn blake3_hash_file(path: String) -> anyhow::Result<String> {
    let mut file = File::open(&path)?;
    let mut hasher = blake3::Hasher::new();
    let mut buf = vec![0u8; 1 << 20]; // 1 MiB chunk

    loop {
        let n = file.read(&mut buf)?;
        if n == 0 {
            break;
        }
        hasher.update(&buf[..n]);
    }

    Ok(hasher.finalize().to_hex().to_string())
}
