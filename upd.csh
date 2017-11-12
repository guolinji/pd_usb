#sed -i 's/^.timescale.*$/ `include "timescale.v"/g' `grep "^.timescale" -l rtl/*.v`
rm -f rtl.tar
tar.exe vcf rtl.tar rtl tb
cp rtl.tar \\\\cn42cm01cifs\\glji
