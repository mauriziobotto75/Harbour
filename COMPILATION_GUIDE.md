# HBMK2 Compilation Guide

## Files in this project

1. **bike_rental.prg** - Harbour source code (the application)
2. **bike_rental.hbp** - Harbour Build Project configuration
3. **Dockerfile** - For compiling in a Docker container
4. **COMPILATION_GUIDE.md** - This file

## Quick Start

### Windows - Direct Installation

```
# 1. Download Harbour from: https://github.com/harbour/core/releases
# Choose the Windows binary package

# 2. Extract to C:\Harbour (or your preferred location)

# 3. Add C:\Harbour\bin to system PATH

# 4. In Command Prompt, navigate to this directory and run:
hbmk2 bike_rental.hbp

# 5. This creates bike_rental.exe
# 6. Run it:
bike_rental.exe
```

### Docker (Linux/Mac/Windows)

```bash
# Build the Docker image
docker build -t bike-rental .

# Compile the application
docker run --rm -v $(pwd):/app bike-rental

# The executable will be in your current directory
```

### Linux/WSL

```bash
# Install Harbour
sudo apt-get update
sudo apt-get install harbour

# Compile
hbmk2 bike_rental.hbp

# Run
./bike_rental
```

## What HBMK2 Does

HBMK2 is Harbour's build tool. The .hbp file specifies:
- What to compile (bike_rental.prg)
- Output name (bike_rental.exe)
- Compiler flags and options

## Generated Files After Compilation

- `bike_rental.exe` - The compiled executable
- `bike_rental.o` or `bike_rental.obj` - Object file
- Database files created at runtime:
  - `biciclette.dbf`, `biciclette.cdx`
  - `clienti.dbf`, `clienti.cdx`
  - `noleggi.dbf`, `noleggi.cdx`

## Troubleshooting

**Error: HBMK2 not found**
→ Install Harbour or add it to PATH

**Error: REQUEST DBFCDX not found**
→ Ensure full Harbour installation (includes RDD libraries)

**Database locked error**
→ Close all DBF files before running again

## Features of the Application

✓ Bicycle rental management
✓ Client registry with indexed lookups
✓ Rental start with deposit/advance payment
✓ Rental return with automatic time calculation
✓ Hourly rate calculation with minimum billing
✓ Booking verification
✓ Auto-create and populate database

## Next Steps

1. Install Harbour/HBMK2
2. Run: `hbmk2 bike_rental.hbp`
3. Execute: `bike_rental.exe`
4. Start managing bike rentals!
