import shutil, csv, os, tempfile, sys, argparse, glob
from PIL import Image
from collections import Counter

from libtextureconverter.utils import detect_pixel_size, target_dir, colorize, colorize_alpha, handle_default_minecraft_texture, find_all_minecraft_resourcepacks
from libtextureconverter.convert import convert_textures
from libtextureconverter.config import SUPPORTED_MINECRAFT_VERSION, working_dir, mineclone2_path, appname, home
from libtextureconverter.gui import main as launch_gui

def convert_resource_packs(resource_packs, output_dir, PXSIZE):
    for base_dir in resource_packs:
        print(f"Converting resource pack: {base_dir}")

        # Autodetect pixel size if not provided
        if not PXSIZE:
            pixel_size = detect_pixel_size(base_dir)
        else:
            pixel_size = PXSIZE
        # Construct the path to the textures within the resource pack
        tex_dir = os.path.join(base_dir, "assets", "minecraft", "textures")

        # Determine the name of the output directory for the converted texture pack
        output_dir_name = os.path.basename(os.path.normpath(base_dir))

        # Create the output directory if it doesn't exist
        output_path = os.path.join(output_dir, output_dir_name)
        if not os.path.isdir(output_path):
            os.makedirs(output_path, exist_ok=True)

        # Temporary files for conversion (if needed by your conversion process)
        tempfile1 = tempfile.NamedTemporaryFile(delete=False)
        tempfile2 = tempfile.NamedTemporaryFile(delete=False)

        try:
            # Perform the actual conversion
            convert_textures(
                base_dir=base_dir,
                tex_dir=tex_dir,
                temp_files=(tempfile1.name, tempfile2.name),
                output_dir=output_path,
                pixel_size=pixel_size
            )
        finally:
            # Clean up temporary files
            tempfile1.close()
            os.unlink(tempfile1.name)
            tempfile2.close()
            os.unlink(tempfile2.name)

        print(f"Finished converting resource pack: {base_dir}")
