{
  description = "Nix flake for whisper.cpp";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        whisperSrc = builtins.fetchGit {
          url = "https://github.com/ggerganov/whisper.cpp";
          rev = "09e90680072d8ecdf02eaf21c393218385d2c616";
        };

        models = {
          tiny = builtins.fetchurl {
            url = "https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin";
            sha256 = "sha256:07qbja4m5isssw42prv227gbyrf3nsjms6h8rlyrkpbgd3w4q7lj";
          };
          base = builtins.fetchurl {
            url = "https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
            sha256 = "sha256:00nhqqvgwyl9zgyy7vk9i3n017q2wlncp5p7ymsk0cpkdp47jdx0";
          };
          small = builtins.fetchurl {
            url = "https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin";
            sha256 = "sha256:0p8yqkwvpl9lyy43yajk305bps0v5z1qgyg0jwh35j7cb1nqs4y6";
          };
          medium = builtins.fetchurl {
            url = "https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-medium.en.bin";
            sha256 = "sha256:0mj3vbvaiyk5x2ids9zlp2g94a01l4qar9w109qcg3ikg0sfjdyc";
          };
          large = builtins.fetchurl {
            url = "https://huggingface.co/datasets/ggerganov/whisper.cpp/resolve/main/ggml-large.en.bin";
            sha256 = "";
          };
        };

        whisper-stream = pkgs.stdenv.mkDerivation {
          pname = "whisper-cpp";
          version = "0.1.0";
          src = whisperSrc;

          buildInputs = with pkgs; [ SDL2 pkg-config ];

          buildPhase = ''
            make stream
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp stream $out/bin
            chmod +x $out/bin/stream
          '';

        };

        whisper-cpp-stream-tiny = pkgs.stdenv.mkDerivation {
          name = "whisper-cpp-stream-tiny";
          buildInputs = [ whisper-stream ];
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/bin
            echo '#!/usr/bin/env sh' >> $out/bin/whisper-cpp-stream-tiny
            echo "${whisper-stream}/bin/stream -m ${models.tiny} \$@" >> $out/bin/whisper-cpp-stream-tiny
            chmod +x $out/bin/whisper-cpp-stream-tiny
          '';
        };

        whisper-cpp-stream-small = pkgs.stdenv.mkDerivation {
          name = "whisper-cpp-stream-small";
          buildInputs = [ whisper-stream ];
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/bin
            echo '#!/usr/bin/env sh' >> $out/bin/whisper-cpp-stream-small
            echo "${whisper-stream}/bin/stream -m ${models.small} \$@" >> $out/bin/whisper-cpp-stream-small
            chmod +x $out/bin/whisper-cpp-stream-small
          '';
        };

        whisper-cpp-stream-base = pkgs.stdenv.mkDerivation {
          name = "whisper-cpp-stream-base";
          buildInputs = [ whisper-stream ];
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/bin
            echo '#!/usr/bin/env sh' >> $out/bin/whisper-cpp-stream-base
            echo "${whisper-stream}/bin/stream -m ${models.base} \$@" >> $out/bin/whisper-cpp-stream-base
            chmod +x $out/bin/whisper-cpp-stream-base
          '';
        };

        whisper-cpp-stream-medium = pkgs.stdenv.mkDerivation {
          name = "whisper-cpp-stream-medium";
          buildInputs = [ whisper-stream ];
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/bin
            echo '#!/usr/bin/env sh' >> $out/bin/whisper-cpp-stream-medium
            echo "${whisper-stream}/bin/stream -m ${models.medium} \$@" >> $out/bin/whisper-cpp-stream-medium
            chmod +x $out/bin/whisper-cpp-stream-medium
          '';
        };

        whisper-cpp-stream-large = pkgs.stdenv.mkDerivation {
          name = "whisper-cpp-stream-large";
          buildInputs = [ whisper-stream ];
          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/bin
            echo '#!/usr/bin/env sh' >> $out/bin/whisper-cpp-stream-large
            echo "${whisper-stream}/bin/stream -m ${models.large} \$@" >> $out/bin/whisper-cpp-stream-large
            chmod +x $out/bin/whisper-cpp-stream-large
          '';
        };

      in
      {
        defaultPackage = whisper-cpp-stream-base;
        packages.whisper-cpp-stream-tiny = whisper-cpp-stream-tiny;
        packages.whisper-cpp-stream-small = whisper-cpp-stream-small;
        packages.whisper-cpp-stream-base = whisper-cpp-stream-base;
        packages.whisper-cpp-stream-medium = whisper-cpp-stream-medium;
        packages.whisper-cpp-stream-large = whisper-cpp-stream-large;
      }
    );
}
