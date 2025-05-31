PREFIX = /usr/local

BIN = dmenu-cocoa
SRC = main.m app_delegate.m window.m options_view.m nsstring+fuzzy.m nscolor+hex.m options.m

all: $(BIN)

config.h: config.def.h
	cp config.def.h config.h

$(BIN): $(SRC) config.h
	clang -O3 -flto -DNDEBUG -Wall -Wextra -Werror -fvisibility=hidden \
            -isysroot $(shell xcrun --sdk macosx --show-sdk-path) \
            -mmacosx-version-min=11.0 \
            -framework Cocoa \
            -arch x86_64 -arch arm64 \
            -o $(BIN) $(SRC)
	codesign --timestamp --options runtime --sign - --force -vvvvvv $(BIN)

install: $(BIN)
	install -Dm755 $(BIN) $(PREFIX)/bin/$(BIN)
	ln -s $(BIN) $(PREFIX)/bin/dmenu

run: $(BIN)
	./$(BIN)

clean:
	rm $(BIN)
