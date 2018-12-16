unit LibVMDK;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{/*
  * Module providing Delphi bindings for the Library libVMDK
  *
  * Copyright (c) 2014, Erwan LABALEC <erwan2212@gmail.com>,
  *
  * This software is free software: you can redistribute it and/or modify
  * it under the terms of the GNU Lesser General Public License as published by
  * the Free Software Foundation, either version 3 of the License, or
  * (at your option) any later version.
  *
  * This software is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * You should have received a copy of the GNU Lesser General Public License
  * along with this software.  If not, see <http://www.gnu.org/licenses/>.
  */}


interface

uses
  Windows,
  SysUtils;

type
  TINT16 = short;
  TUINT16 = word;
  TUINT8 = byte;
  PlibHDL = pointer;
  TSIZE = longword;
  TSIZE64 = int64;
  PSIZE64 = ^int64;

 Tlibvmdkhandleinitialize=function(handle : PLIBHDL;error:pointer) : integer; cdecl; //pointer to PLIBHDL
 Tlibvmdkhandlefree=function(handle : PLIBHDL;error:pointer) : integer; cdecl;  //pointer to PLIBHDL
 Tlibvmdkhandleopen=function(handle : PLIBHDL;filename : pansichar; flags : integer;error:pointer) : integer; cdecl;
 Tlibvmdkhandleopenwide=function(handle : PLIBHDL;filename : pwidechar; flags : integer;error:pointer) : integer; cdecl;
 Tlibvmdkhandleclose=function(handle : PLIBHDL;error:pointer) : integer; cdecl;
 Tlibvmdkhandlegetmediasize = function(handle : PLIBHDL; media_size : PSIZE64;error:pointer) : integer; cdecl;
 Tlibvmdkhandlewritebuffer = function(handle : PLIBHDL; buffer : pointer; size : TSIZE; offset : TSIZE64;error:pointer) : integer; cdecl;
 Tlibvmdkhandlereadbufferatoffset = function(handle : PLIBHDL; buffer : pointer; size : TSIZE; offset : TSIZE64;error:pointer) : integer; cdecl;
 Tlibvmdkhandleopenextentdatafiles = function(handle : PLIBHDL;error:pointer) : integer; cdecl;
 Tlibvmdkhandleseekoffset= function(handle : PLIBHDL; offset : TSIZE64;whence:integer;error:pointer) : TSIZE64; cdecl;
 Tlibvmdkhandlereadbuffer=function(handle : PLIBHDL; buffer : pointer; size : TSIZE; error:pointer) : integer; cdecl;

  TLibVMDK = class(TObject)
  private
        fLibHandle : THandle;
        fCurHandle : PlibHDL;

        flibvmdkhandleopen:Tlibvmdkhandleopen ;
        flibvmdkhandleopenwide:Tlibvmdkhandleopenwide ;
        flibvmdkhandleclose:Tlibvmdkhandleclose ;
        flibvmdkhandleinitialize:Tlibvmdkhandleinitialize ;
        flibvmdkhandlefree:Tlibvmdkhandlefree ;
        flibvmdkhandleopenextentdatafiles:Tlibvmdkhandleopenextentdatafiles;
        flibvmdkhandlereadbufferatoffset:Tlibvmdkhandlereadbufferatoffset;
        flibvmdkhandlewritebuffer:Tlibvmdkhandlewritebuffer;
        flibvmdkhandlegetmediasize:Tlibvmdkhandlegetmediasize;
        flibvmdkhandleseekoffset:Tlibvmdkhandleseekoffset;
        flibvmdkhandlereadbuffer:Tlibvmdkhandlereadbuffer;

  public
        constructor create();
        destructor destroy(); override;
        function libvmdk_open(const filename : ansistring;flag:byte=$1) : integer;
        function libvmdk_open_wide(const filename : widestring;flag:byte=$1) : integer;
        function libvmdk_open_extent_data_files() : integer;
        function libvmdk_read_buffer_at_offset(buffer : pointer; size : longword; offset : int64) : integer;
        function libvmdk_write_buffer(buffer : pointer; size : longword; offset : int64) : integer;
        function libvmdk_get_media_size() : int64;
        function libvmdk_close() : integer;
  end;

const
        libvmdk_OPEN_READ = $01;
        libvmdk_OPEN_WRITE = $02;

        SEEK_CUR =   1;
        SEEK_END =   2;
        SEEK_SET  =  0;

implementation

constructor TLibVMDK.create();
var
        libFileName : ansistring;
begin
        fLibHandle:=0;
        fCurHandle:=nil;

        //libFileName:=ExtractFilePath(Application.ExeName)+'libvmdk.dll';//-new.dll';
        //libFileName :=GetCurrentDir +'\libvmdk.dll';
        libFileName:=ExtractFilePath(ParamStr(0))+'libvmdk.dll';//-new.dll';
        if fileExists(libFileName) then
        begin
                fLibHandle:=LoadLibraryA(PAnsiChar(libFileName));
                if fLibHandle<>0 then
                begin
                        @flibvmdkhandleinitialize:=GetProcAddress(fLibHandle,'libvmdk_handle_initialize');
                        @flibvmdkhandlefree:=GetProcAddress(fLibHandle,'libvmdk_handle_free');
                        @flibvmdkhandleopen:=GetProcAddress(fLibHandle,'libvmdk_handle_open');
                        @flibvmdkhandleopenwide:=GetProcAddress(fLibHandle,'libvmdk_handle_open_wide');
                        @flibvmdkhandleopenextentdatafiles:=GetProcAddress(fLibHandle,'libvmdk_handle_open_extent_data_files');
                        @flibvmdkhandleclose:=GetProcAddress(fLibHandle,'libvmdk_handle_close');
                        @flibvmdkhandlereadbufferatoffset:=GetProcAddress(fLibHandle,'libvmdk_handle_read_buffer_at_offset');
                        @flibvmdkhandlewritebuffer:=GetProcAddress(fLibHandle,'libvmdk_handle_write_buffer');
                        @flibvmdkhandlegetmediasize:=GetProcAddress(fLibHandle,'libvmdk_handle_get_media_size');
                        @flibvmdkhandleseekoffset:=GetProcAddress(fLibHandle,'libvmdk_handle_seek_offset');
                        @flibvmdkhandlereadbuffer:=GetProcAddress(fLibHandle,'libvmdk_handle_read_buffer');
                 end;
        end
        else raise exception.Create ('could not find libvmdk.dll');
end;

destructor Tlibvmdk.destroy();
begin
        if (fCurHandle<>nil) then
        begin
                libvmdk_close();
                FreeLibrary(fLibHandle);
        end;
        inherited;
end;

function Tlibvmdk.libvmdk_open_extent_data_files() : integer;
var
err:pointer;
buf:array[0..63] of dword;
w:array[0..63] of widechar;
p:pointer;
begin
err:=nil;
Result:=-1;
result:=flibvmdkhandleopenextentdatafiles(fCurHandle,@err);

end;

{/*
  * Open an entire (even multipart)  file.
  * @param filename - the first (.e01) file name.
  * @return 0 if successful and valid, -1 otherwise.
  */}
function Tlibvmdk.libvmdk_open(const filename : ansistring;flag:byte=$1) : integer;
var
        err:pointer;
        ret:integer;
begin
        err:=nil;
        Result:=-1;
        ret:=flibvmdkhandleinitialize (@fCurHandle,@err); //pointer to pointer = ** in c
        if ret=1
           then if flibvmdkhandleopen (fCurHandle,pchar(fileName), flag,@err)<>1
                then {raise exception.Create('flibvmdkhandleopen failed')};
        if fCurHandle<>nil then  Result:=0;
end;

function Tlibvmdk.libvmdk_open_wide(const filename : widestring;flag:byte=$1) : integer;
var
        err:pointer;
        ret:integer;
begin
        err:=nil;
        Result:=-1;
        ret:=flibvmdkhandleinitialize (@fCurHandle,@err); //pointer to pointer = ** in c
        if ret=1
           then if flibvmdkhandleopenwide (fCurHandle,pwidechar(fileName), flag,@err)<>1
                then {raise exception.Create('flibvmdkhandleopen failed')};
        if fCurHandle<>nil then  Result:=0;
end;


{/*
  * Read an arbitrary part of the  file.
  * @param buffer : pointer - pointer to a preallocated buffer (byte array) to read into.
  * @param size - The number of bytes to read
  * @param offset - The position within the  file.
  * @return The number of bytes successfully read, -1 if unsuccessful.
  */}
function Tlibvmdk.libvmdk_read_buffer_at_offset(buffer : pointer; size : longword; offset : int64) : integer;
var
err:pointer;
begin
        err:=nil;
        Result:=-1;
        if fLibHandle<>0 then
        begin
        {if flibvmdkhandleseekoffset (fCurHandle ,offset,seek_set,@err)<>-1
          then result:=flibvmdkhandlereadbuffer(fCurHandle ,buffer,size,@err);}
        Result:=flibvmdkhandlereadbufferatoffset(fCurHandle, buffer, size, offset,@err);
        end;
end;

{/*
  * write an arbitrary part of the  file.
  * @param buffer : pointer - pointer to a preallocated buffer (byte array) to write from.
  * @param size - The number of bytes to write
  * @param offset - The position within the  file.
  * @return The number of bytes successfully written, -1 if unsuccessful.
  */}
function Tlibvmdk.libvmdk_write_buffer(buffer : pointer; size : longword; offset : int64) : integer;
var
err:pointer;
begin
        err:=nil;
        Result:=-1;
        if fLibHandle<>0 then
        begin
        Result:=flibvmdkhandlewritebuffer(fCurHandle, buffer, size, offset,@err);
        end;
end;



{/*
  * Get the total true size of the  file.
  * @return The size of the  file in bytes, -1 if unsuccessful.
  */}
function Tlibvmdk.libvmdk_get_media_size() : int64;
var
        resInt64 :Int64;
        err:pointer;
begin
        err:=nil;
        Result:=-1;
        resInt64:=-1;
        if (fLibHandle<>0) and (fCurHandle<>nil) then
        begin
          flibvmdkhandlegetmediasize (fCurHandle,@resInt64,@err);
          Result:=resInt64;
        end;
end;


{/*
  * Close the  file.
  * @return 0 if successful, -1 otherwise.
  */}
function Tlibvmdk.libvmdk_close() : integer;
var
err:pointer;
begin
        err:=nil;
        if fLibHandle<>0 then
        begin
        Result:=flibvmdkhandleclose (fCurHandle,@err);
        if result=0 then result:=flibvmdkhandlefree (@fCurHandle,@err);
        fCurHandle:=0;
        end;
end;

end.

