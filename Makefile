
# Apple clang does not support C++ Modules at the moment
# @see https://stackoverflow.com/a/70218679
CLANG_BIN_PATH=/opt/homebrew/opt/llvm/bin/clang++
TARGET=main
CXX=$(CLANG_BIN_PATH)
LD=$(CLANG_BIN_PATH)
SOURCE_DIR=.
BUILD_DIR=build
CXXFLAGS=-std=c++20 \
-stdlib=libc++ \
-fmodules \
-fprebuilt-module-path=$(BUILD_DIR)

MODULES=$(wildcard $(SOURCE_DIR)/*.ccm)
PRECOMPILED=$(patsubst $(SOURCE_DIR)/%.ccm, $(BUILD_DIR)/%.pcm, $(MODULES))

SOURCES=$(wildcard $(SOURCE_DIR)/*.cc)
OBJECTS=$(patsubst $(SOURCE_DIR)/%.cc, $(BUILD_DIR)/%.o, $(SOURCES))

all: $(BUILD_DIR) $(TARGET)

# linkage
$(TARGET): $(PRECOMPILED) $(OBJECTS)
	$(LD) -o $(TARGET) $(PRECOMPILED) $(OBJECTS)

# precompiled modules
$(BUILD_DIR)/%.pcm: $(SOURCE_DIR)/%.ccm
	$(CXX) $(CXXFLAGS) --precompile -x c++-module $< -o $@

# object files
$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

clean: $(BUILD_DIR)
	rm -f $(BUILD_DIR)/*.o $(BUILD_DIR)/*.pcm $(BUILD_DIR)/*.d
	rm -f $(TARGET)
