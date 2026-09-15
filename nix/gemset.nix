{
  bigdecimal = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0rng45p4vc3f6nac44cnylwch7rj4zsff3icdz6c7garwpjy3sv1";
      type = "gem";
    };
    version = "4.1.3";
  };
  dry-cli = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0x6qlxk6zp3jw748k6x3zkpywx9yjyagdyinb9qai2khdjvmn0dq";
      type = "gem";
    };
    version = "1.4.1";
  };
  gum = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0mqyjck7fzq72p98d6q47k1w8yh1khypc90gacn1png51majp002";
      type = "gem";
    };
    version = "0.3.2";
  };
  hana = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "03cvrv2wl25j9n4n509hjvqnmwa60k92j741b64a1zjisr1dn9al";
      type = "gem";
    };
    version = "1.3.7";
  };
  json_schemer = {
    dependencies = [
      "bigdecimal"
      "hana"
      "regexp_parser"
      "simpleidn"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "15p31bq932bfpsi1wgrkgwm71l7z1h1w53q6vl44w6kjrr6gn09g";
      type = "gem";
    };
    version = "2.5.0";
  };
  regexp_parser = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1fwfw26a32rps78920nn29shqg2zmqv72i89j1fap41isshida9m";
      type = "gem";
    };
    version = "2.12.0";
  };
  simpleidn = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "00sdym5q3d9zg7lv47mjamzv67z1lfyd3gz9256v0g9gxl5p7jhj";
      type = "gem";
    };
    version = "0.3.0";
  };
  snippet_cli = {
    dependencies = [
      "dry-cli"
      "gum"
      "json_schemer"
      "tty-cursor"
    ];
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "1x36alwfjbpka4cgmdk4jsl7xiszwjm0dn5fgy89yz1a56m58c9a";
      type = "gem";
    };
    version = "0.5.3";
  };
  tty-cursor = {
    groups = [ "default" ];
    platforms = [ ];
    source = {
      remotes = [ "https://rubygems.org" ];
      sha256 = "0j5zw041jgkmn605ya1zc151bxgxl6v192v2i26qhxx7ws2l2lvr";
      type = "gem";
    };
    version = "0.7.1";
  };
}
