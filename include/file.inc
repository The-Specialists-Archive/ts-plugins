/* Files functions
*
* by the AMX Mod X Development Team
*  originally developed by OLO
*
* This file is provided as is (no warranties).
*/

#if defined _file_included
  #endinput
#endif
#define _file_included

/* Reads content from directory.
* Returns index of next element or 0 when end of dir. is reached. */
native read_dir(const dirname[],pos,output[],len,&outlen);

/* Reads line from file. Returns index of next line or 0 when end of file is reached. */
native read_file(const file[],line,text[],len,&txtlen);

/* Writes text to file. Function returns 0 on failure.
* When line is set to -1, the text is added at the end of file. */
native write_file(const file[],const text[],line = -1);

/* Deletes file. Function returns 1 on success, 0 on failure. */
native delete_file(const file[]);

/* Checks for file. If file exists function returns 1, in other case 0. */
native file_exists(const file[]);

/* Checks if a directory exists */
native dir_exists(const dir[]);

/* Returns a file size in bytes if flag is set to 0.
* When flag is set to 1 returns number of lines in the file,
* and when flags is 2, function returns 1 if the file ends
* with line feed. If file doesn't exist returns -1. */
native file_size(const file[], flag=0);

#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2

//Open a file, returns a handle or 0 on vailure
native fopen(const filename[],const mode[]);

//Closes a file handle
native fclose(file);

#define BLOCK_INT	4
#define BLOCK_SHORT	2
#define BLOCK_CHAR	1
#define BLOCK_BYTE	1

//The following functions work as such:
// RAW - means the array you pass is a raw bytestream, for experts only
// BLOCK - means you are passing in an array where each element will be written
// NORMAL - means you are writing only one element
// RAW and BLOCK return the number of blocks acted upon successfully
// NORMAL returns 1 on success

native fread(file, &data, mode);
native fread_blocks(file, data[], blocks, mode);
native fread_raw(file, stream[], blocksize, blocks);
native fwrite(file, data, mode);
native fwrite_blocks(file, const data[], blocks, mode);
native fwrite_raw(file, const stream[], blocksize, mode);

//Returns 1 if the file is ended, 0 otherwise
native feof(file);

//Reads a line from a text file -- includes newline!
native fgets(file, buffer[], maxlength);

//Writes a line to the file
native fprintf(file, const fmt[], {Float,Sql,Result_}:...);

//Sets the current position in a file (see SEEK_ values above)
native fseek(file, position, start);

//Returns the current position in a file
native ftell(file);

//These are straight from the C standard.
native fgetc(file);
native fputc(file, data);
native fungetc(file, data);

//Return the size of a file
native filesize(const filename[],{Float,Sql,Result,_}:...);

//Attempts to remove a directory.
//Note that you cannot remove a directory that has files on most
// operating systems.
native rmdir(const path[]);

//Delete a file (delete_file macro)
native unlink(const filename[],{Float,Sql,Result,_}:...);

//Returns a handle to a directory
native open_dir(dir[], firstfile[], length);
native next_file(dirh, buffer[], length);
native close_dir(dirh);
