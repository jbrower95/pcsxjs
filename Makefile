CC=emcc
OPTIMIZATION_FLAGS= -03
CFLAGS= -sASSERTIONS -gsource-map -Wno-unused-result \
-D USESDLSOUND  -s USE_ZLIB=1 -I./include -I./libpcsxcore

EM_ARGS= -sEXPORTED_RUNTIME_METHODS=ccall,cwrap

# WORKER
WORKER_EXPORT="['_main',  '_pcsx_init', '_one_iter', '_get_ptr', '_ls', 'getValue', 'setValue']"
WORKER_OBJS=gui/workerMain.o gui/Plugin.o gui/Config.o \
libpcsxcore/psxbios.o libpcsxcore/cdrom.o libpcsxcore/psxcounters.o \
libpcsxcore/psxdma.o libpcsxcore/disr3000a.o libpcsxcore/spu.o libpcsxcore/sio.o \
libpcsxcore/psxhw.o libpcsxcore/mdec.o libpcsxcore/psxmem.o libpcsxcore/misc.o \
libpcsxcore/plugins.o libpcsxcore/decode_xa.o libpcsxcore/r3000a.o libpcsxcore/psxinterpreter.o \
libpcsxcore/gte.o libpcsxcore/psxhle.o  libpcsxcore/psxcommon.o \
libpcsxcore/cdriso.o libpcsxcore/ppf.o   \
plugins/dfxvideo/cfg.o   plugins/dfxvideo/fps.o plugins/dfxvideo/key.o \
plugins/dfxvideo/prim.o  plugins/dfxvideo/zn.o plugins/dfxvideo/draw_null.o  \
plugins/dfxvideo/gpu.o   plugins/dfxvideo/soft.o \
plugins/dfsound/spu.o plugins/dfsound/cfg.o  plugins/dfsound/dma.o plugins/dfsound/registers.o plugins/dfsound/worker.o \
plugins/sdlinput/cfg.o     plugins/sdlinput/pad_worker.o plugins/sdlinput/analog.o
WORKER_FLAGS= --post-js worker_funcs.js -s TOTAL_MEMORY=419430400 -sEXPORTED_FUNCTIONS=$(WORKER_EXPORT) $(EM_ARGS)

UI_EXPORT="['_main','_get_ptr', '_render','_LoadPADConfig', '_CheckKeyboard', '_CheckJoy', '_SoundFeedStreamData', '_SoundGetBytesBuffered']"
UI_OBJS=plugins/sdlinput/cfg.o plugins/sdlinput/xkb.o gui/wwGUI.o \
plugins/sdlinput/sdljoy.o plugins/sdlinput/analog.o plugins/dfsound/sdl.o  
UI_FLAGS=-sEXPORTED_FUNCTIONS=$(UI_EXPORT) -s TOTAL_MEMORY=16777216 -sFORCE_FILESYSTEM -lidbfs.js $(EM_ARGS)


ALL: pcsx_worker.js pcsx_ww.js

%.o: %.c
	$(CC) -c -o $@ $< $(CFLAGS)

%.o: %.cc
	$(CC) -x c++ -std=c++14 -c -o $@ $< $(CFLAGS)

gui/xbrz.o: gui/xbrz.cpp gui/xbrz.h
	$(CC) -c -o $@ $(CFLAGS) -x c++ -std=c++14 -DNDEBUG $<

pcsx_worker.js: $(WORKER_OBJS) worker_funcs.js
	$(CC) -o $@ $(CFLAGS) $(WORKER_OBJS) $(WORKER_FLAGS)

pcsx_ww.js: $(UI_OBJS)
	$(CC) -o $@ $(CFLAGS) $(UI_OBJS) $(UI_FLAGS)

clean:
	rm -f *.o */*.o */*/*.o