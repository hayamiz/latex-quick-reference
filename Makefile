
GAUCHE_VERSION := Gauche-0.8.14

.PHONY: clean

clean:
	rm -f $(GAUCHE_VERSION).tgz

gauche: $(GAUCHE_VERSION).tgz
	tar zxvf $(GAUCHE_VERSION).tgz
	mv $(GAUCHE_VERSION) gauche
	cd gauche; ./configure --prefix=$$(pwd); make -j4; make install

$(GAUCHE_VERSION).tgz:
	wget "http://unicus.ddo.jp/haya/$(GAUCHE_VERSION).tgz"

