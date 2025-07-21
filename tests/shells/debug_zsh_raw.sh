#!/bin/zsh
# Debug raw .env file reading in Zsh

echo "Debugging raw .env file reading..."

# Check the raw line from .env.example
echo "Raw line from .env.example:"
grep "WINDOWS_PATH=" .env.example

echo ""
echo "Hex dump of the raw line:"
grep "WINDOWS_PATH=" .env.example | xxd

echo ""
echo "Testing direct assignment:"
WINDOWS_PATH="C:\\Users\\Developer\\AppData\\Local"
echo "Direct assignment result: [$WINDOWS_PATH]"
echo "Hex dump:"
echo -n "$WINDOWS_PATH" | xxd

echo ""
echo "Testing with different quoting:"
WINDOWS_PATH='C:\Users\Developer\AppData\Local'
echo "Single quote result: [$WINDOWS_PATH]"
echo "Hex dump:"
echo -n "$WINDOWS_PATH" | xxd
