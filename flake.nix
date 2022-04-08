{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell.${system} = pkgs.mkShell {
        buildInputs = with pkgs; [
          cowsay
          hivemind
          redis
          ruby_2_7
	  postgresql_13
        ];
        shellHook = ''
          # Project-local PostgreSQL server
          export PGDATA="''${PWD}/.direnv/postgres"
          export PGHOST="''${PGDATA}"
          if [[ ! -d "''${PGDATA}" ]]; then
            initdb --auth=trust
            cat << EOF > "''${PGDATA}/postgresql.conf"
          listen_addresses = '''
          unix_socket_directories = ' ''${PGHOST}'
          EOF
          fi
          
          # Project-local Redis server
          redis_directory=".direnv/redis"
          mkdir -p "''${redis_directory}"
          cat << EOF > "''${redis_directory}/redis.conf"
          dir ''${redis_directory}
          port 0
          unixsocket redis.sock
          EOF

          cowsay "Run 'hivemind' to get started"
        '';
      };
    };
}
