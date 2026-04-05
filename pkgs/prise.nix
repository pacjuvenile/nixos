{ pkgs, prise }:

let
  zigDeps = {
    # 一级依赖
    ghostty = pkgs.fetchurl {
      url = "https://github.com/ghostty-org/ghostty/archive/f6e6bb0238cbf4ce8c154c07f5df8c5109dc9f03.tar.gz";
      sha256 = "sha256-bQI3+uVQa/59nIlpiN47fBK3xH5xTJyYt/Fb8YNX0ns=";
    };
    vaxis = pkgs.fetchurl {
      url = "https://github.com/rockorager/libvaxis/archive/68d6ea1d94fa0e5575e3af505bebab29a15acb96.tar.gz";
      sha256 = "sha256-crEWhDedXmi9+T1I43IqcTmagRev70NNhumdZKuOaZU=";
    };
    zlua = pkgs.fetchurl {
      url = "https://github.com/natecraddock/ziglua/archive/af970851f5412a32c9eceb1c4519679a242c6093.tar.gz";
      sha256 = "sha256-cJPpcg6qJabb3dYoVj/XW76nDv31ZXEm5ZakFZRatNA=";
    };
    zeit = pkgs.fetchgit {
      url = "https://github.com/rockorager/zeit";
      rev = "7ac64d72dbfb1a4ad549102e7d4e232a687d32d8";
      sha256 = "sha256-CDYwSqx0xA3Xx7/eDCtP0lHbheIScPwnffV2nxzJ/mU=";
    };
    # 二级依赖（vaxis 依赖）
    zigimg = pkgs.fetchgit {
      url = "https://github.com/zigimg/zigimg";
      rev = "eab2522c023b9259db8b13f2f90d609b7437e5f6";
      sha256 = pkgs.lib.fakeSha256;
    };
    uucode = pkgs.fetchgit {
      url = "https://github.com/jacobsandlund/uucode";
      rev = "5f05f8f83a75caea201f12cc8ea32a2d82ea9732";
      sha256 = pkgs.lib.fakeSha256;
    };
    # 二级依赖（ghostty 依赖）
    ghostty-uucode = pkgs.fetchurl {
      url = "https://deps.files.ghostty.org/uucode-0.2.0-ZZjBPqZVVABQepOqZHR7vV_NcaN-wats0IB6o-Exj6m9.tar.gz";
      sha256 = pkgs.lib.fakeSha256;
    };
  };

  zigGlobalCache = pkgs.stdenvNoCC.mkDerivation {
    pname = "prise-zig-global-cache";
    version = "0.1.0";

    dontUnpack = true;
    dontPatch = true;
    dontConfigure = true;
    dontFixup = true;

    buildPhase = ''
      mkdir -p $out/p
      cache_dir=$out

      mkdir -p $cache_dir/p/ghostty-1.3.2-dev-5UdBC6LmAwWo-O--rkIn0OW7T9wQY8HGhAxgWQFPGcb8
      tar -xzf ${zigDeps.ghostty} -C $cache_dir/p/ghostty-1.3.2-dev-5UdBC6LmAwWo-O--rkIn0OW7T9wQY8HGhAxgWQFPGcb8 --strip-components=1

      mkdir -p $cache_dir/p/vaxis-0.5.1-BWNV_AAyCQAyuU8AUmRpkPzTW51DmXQ2nG6I-EyrROg_
      tar -xzf ${zigDeps.vaxis} -C $cache_dir/p/vaxis-0.5.1-BWNV_AAyCQAyuU8AUmRpkPzTW51DmXQ2nG6I-EyrROg_ --strip-components=1

      mkdir -p $cache_dir/p/zlua-0.1.0-hGRpCx89BQCdTNT2LiQGKujXawO2jCgB4hGl0WEqj0cz
      tar -xzf ${zigDeps.zlua} -C $cache_dir/p/zlua-0.1.0-hGRpCx89BQCdTNT2LiQGKujXawO2jCgB4hGl0WEqj0cz --strip-components=1

      mkdir -p $cache_dir/p/zeit-0.6.0-5I6bk36tAgATpSl9wjFmRPMqYN2Mn0JQHgIcRNcqDpJA
      cp -r ${zigDeps.zeit}/. $cache_dir/p/zeit-0.6.0-5I6bk36tAgATpSl9wjFmRPMqYN2Mn0JQHgIcRNcqDpJA/

      # 二级依赖
      mkdir -p $cache_dir/p/zigimg-0.1.0-8_eo2vUZFgAAtN1c6dAO5DdqL0d4cEWHtn6iR5ucZJti
      cp -r ${zigDeps.zigimg}/. $cache_dir/p/zigimg-0.1.0-8_eo2vUZFgAAtN1c6dAO5DdqL0d4cEWHtn6iR5ucZJti/

      mkdir -p $cache_dir/p/uucode-0.1.0-ZZjBPj96QADXyt5sqwBJUnhaDYs_qBeeKijZvlRa0eqM
      cp -r ${zigDeps.uucode}/. $cache_dir/p/uucode-0.1.0-ZZjBPj96QADXyt5sqwBJUnhaDYs_qBeeKijZvlRa0eqM/

      mkdir -p $cache_dir/p/uucode-0.2.0-ZZjBPqZVVABQepOqZHR7vV_NcaN-wats0IB6o-Exj6m9
      cp -r ${zigDeps.ghostty-uucode}/. $cache_dir/p/uucode-0.2.0-ZZjBPqZVVABQepOqZHR7vV_NcaN-wats0IB6o-Exj6m9/
    '';

    installPhase = "true";

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = pkgs.lib.fakeSha256;
  };
in
pkgs.stdenv.mkDerivation {
  pname = "prise";
  version = "0.3.1";
  src = prise;

  nativeBuildInputs = with pkgs; [ zig pkg-config ];
  buildInputs = [ pkgs.lua5_4 ];

  postPatch = ''
    mkdir -p $TMPDIR/zig-cache/p
    cp -r ${zigGlobalCache}/p/* $TMPDIR/zig-cache/p/ 2>/dev/null || true
  '';

  buildPhase = ''
    export HOME=$TMPDIR
    export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
    export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-local

    zig build -Doptimize=ReleaseSafe --prefix $out --global-cache-dir $ZIG_GLOBAL_CACHE_DIR
  '';

  installPhase = "true";
}
