{ pkgs ? import <nixpkgs> {
    config = {
        # oops, 16 is now EOL
        permittedInsecurePackages = [ "nodejs-16.20.2" ];
    };
} }:

let
    rust = pkgs.rustc;
    cargo = pkgs.cargo;
    erlang = pkgs.erlang_24;
    elixir = pkgs.elixir_1_13;
    nodejs = pkgs.nodejs_16;
in
pkgs.mkShell {
    buildInputs = [ elixir nodejs rust cargo pkgs.erlang pkgs.postgresql ];

    shellHook = ''
    # spin up the Postgresql container
    docker run --name postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:13

    # create the .env file
    echo "export DATABASE_URL=postgres://postgres:postgres@postgres/postgres" > .env
    echo "export SECRET_KEY_BASE=0d98bff53500feb68c7cbb20c69ff94b5b96fdf2f3dc2677b605e390f534505bb209304ac451b603f3f695eaa8f0bd48
" >> .env
    echo "export URL_HOST=localhost" >> .env
    echo "export URL_SCHEMA=http" >> .env
    echo "export URL_PORT=4000" >> .env

    mix setup
    mix deps.get
    mix ecto.setup
    mix phx.server
    '';
}
