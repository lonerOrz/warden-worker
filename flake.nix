{
  description = "Warden - Bitwarden-compatible server for Cloudflare Workers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          # Build inputs
          buildInputs = with pkgs; [
            # Rust toolchain
            rustup
            cargo
            rustfmt
            clippy
          ];

          # Runtime inputs
          nativeBuildInputs = with pkgs; [
            # Node.js ecosystem
            nodejs_22
            nodePackages.npm
            # Cloudflare Wrangler
            wrangler
          ];

          RUSTUP_TOOLCHAIN = "1.91.1";

          # Shell environment
          shellHook = ''
            # Auto-install Rust toolchain from rust-toolchain.toml
            if [ -f "$PRJ_ROOT/rust-toolchain.toml" ]; then
              rustup show
            fi

            # Install WASM target if not present
            rustup target add wasm32-unknown-unknown 2>/dev/null || true

            # Show welcome message
            echo "============================================"
            echo "  Warden Development Environment"
            echo "============================================"
            echo "Available commands:"
            echo "  cargo fmt          - Format Rust code"
            echo "  cargo clippy      - Lint Rust code"
            echo "  cargo build       - Build for WASM"
            echo "  wrangler dev      - Start local dev server"
            echo "  wrangler deploy   - Deploy to Cloudflare"
            echo ""
          '';
        };

        packages = {
          default = self.devShells.${system}.default;
        };
      }
    );
}
