LOVE_FILE = dont_touch.love
all: clean
	zip $(LOVE_FILE) main.lua conf.lua
clean: 
	rm -f $(LOVE_FILE)
run:
	love $(LOVE_FILE)