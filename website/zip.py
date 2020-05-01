import zipfile as zf, sys

z = zf.ZipFile(sys.argv[1], "a")
z.write(sys.argv[2], sys.argv[3])
z.close()
# myfile.zip source/dir/file.txt dir/in/zip/file.txt
# This will open myfile.zip and add source/dir/file.txt from the file system as dir/in/zip/file.txt in the zip file.

