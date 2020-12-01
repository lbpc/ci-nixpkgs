{ stdenv, writeScript, curl, perl, python, mdadm, gnugrep, coreutils, jq, findutils, docker }:

stdenv.mkDerivation rec {
  name = "zabbix-scripts";
  src = builtins.fetchGit {
    url = "git@gitlab.intr:staff/zabbix-scripts.git";
    ref = "master";
  };
  builder = writeScript "builder.sh" ''
    source $stdenv/setup
    mkdir -p $out/share/zabbix-scripts
    export PATH=${python}/bin:${perl}/bin:${mdadm}/bin:$PATH
    for file in $src/*; do
      cp $file .
      patchShebangs $(basename $file)
      sed -i 's@/sbin/mdadm@${mdadm}/bin/mdadm@g' $(basename $file)
      export curl=${curl}
      export gnugrep=${gnugrep}
      export coreutils=${coreutils}
      export jq=${jq}
      export findutils=${findutils}
      export docker=${docker}
      substituteAllInPlace "$(basename $file)"
      cp ./$(basename $file) $out/share/zabbix-scripts
    done
  '';
}
