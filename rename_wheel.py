#!/usr/bin/env python3
import sys
import shutil
import subprocess
from pathlib import Path

def rename_wheel(wheel_path_str, target_version, out_dir_str):
    wheel_path = Path(wheel_path_str).resolve()
    out_dir = Path(out_dir_str).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    
    filename = wheel_path.name
    parts = filename[:-4].split('-')
    if len(parts) < 4:
        print(f"  -> Skipping {filename}: not a standard wheel format")
        return
    
    pkg_name = parts[0]
    old_version = parts[1]
    
    if old_version == target_version:
        print(f"  -> Version already matches {target_version}. Copying {filename}...")
        shutil.copy2(wheel_path, out_dir / filename)
        return
        
    print(f"  -> Re-tagging {filename} to version {target_version}...")
    
    tmp_dir = out_dir / f"tmp_{filename}"
    if tmp_dir.exists():
        shutil.rmtree(tmp_dir)
    tmp_dir.mkdir(parents=True)
    
    # Unpack the wheel using the standard wheel CLI
    subprocess.check_call([sys.executable, "-m", "wheel", "unpack", str(wheel_path), "-d", str(tmp_dir)], stdout=subprocess.DEVNULL)
    
    unpack_dirs = list(tmp_dir.iterdir())
    if len(unpack_dirs) != 1:
        print(f"Error: expected 1 unpacked directory for {filename}, found {len(unpack_dirs)}")
        return
    unpacked_dir = unpack_dirs[0]
    
    # Locate the .dist-info folder
    dist_info = None
    for item in unpacked_dir.iterdir():
        if item.is_dir() and item.name.endswith('.dist-info'):
            dist_info = item
            break
            
    if not dist_info:
        print(f"Error: could not find .dist-info inside {unpacked_dir.name}")
        return
        
    # Read METADATA and change Version: field
    metadata_file = dist_info / "METADATA"
    if metadata_file.exists():
        lines = metadata_file.read_text(encoding="utf-8").splitlines()
        for i, line in enumerate(lines):
            if line.startswith("Version: "):
                lines[i] = f"Version: {target_version}"
                break
        metadata_file.write_text("\n".join(lines) + "\n", encoding="utf-8")
        
    # Rename .dist-info to match target version
    dist_info_prefix = dist_info.name.split('-')[0]
    new_dist_info = unpacked_dir / f"{dist_info_prefix}-{target_version}.dist-info"
    dist_info.rename(new_dist_info)
    
    # Rename the parent unpacked directory
    unpacked_prefix = unpacked_dir.name.split('-')[0]
    new_unpacked_dir = tmp_dir / f"{unpacked_prefix}-{target_version}"
    unpacked_dir.rename(new_unpacked_dir)
    
    # Repack. 'wheel pack' will automatically regenerate RECORD checksums.
    subprocess.check_call([sys.executable, "-m", "wheel", "pack", str(new_unpacked_dir), "-d", str(out_dir)], stdout=subprocess.DEVNULL)
    
    # Cleanup
    shutil.rmtree(tmp_dir)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python rename_wheel.py <wheel_path> <target_version> <out_dir>")
        sys.exit(1)
        
    rename_wheel(sys.argv[1], sys.argv[2], sys.argv[3])
