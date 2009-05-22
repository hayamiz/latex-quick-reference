
GAUCHE_VERSION := Gauche-0.8.14

.PHONY: clean gauche

clean:
	rm -f $(GAUCHE_VERSION).tgz

gauche: $(GAUCHE_VERSION).tgz
	tar zxvf $(GAUCHE_VERSION).tgz
	mv $(GAUCHE_VERSION) gauche
	cd gauche; ./configure; make

$(GAUCHE_VERSION).tgz:
	wget "http://unicus.ddo.jp/haya/$(GAUCHE_VERSION).tgz"

