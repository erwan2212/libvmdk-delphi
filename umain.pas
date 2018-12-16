unit umain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,libvmdk, ComCtrls,clipbrd;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    pb_img: TProgressBar;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



var
  Form1: TForm1;
  //
  vmdk:Tlibvmdk;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
mediaSize:int64;
tmp:string;
begin
OpenDialog1.Filter :='VMDK|*.VMDK';
if OpenDialog1.Execute=false then exit;
vmdk:=TLibVMDK.create ;
if vmdk.libvmdk_open (OpenDialog1.FileName )=0 then
  begin
  mediaSize:=vmdk.libvmdk_get_media_size ;
  if mediaSize >0 then
    begin
    tmp:=inttostr(mediasize)+' Bytes'+#13#10+inttostr(mediasize div 1024)+' KBytes'+#13#10+inttostr(mediasize div 1024 div 1024)+' MBytes';
    showmessage(tmp+#13#10+#13#10+'data pasted in clipboard');
    Clipboard.AsText := tmp;
    end
    else showmessage('libvmdk_get_media_size failed');
  end;
vmdk.libvmdk_close ;
FreeAndNil(vmdk);
end;



procedure TForm1.Button2Click(Sender: TObject);
var
ipos,mediasize:int64;
lengthRead:integer;
buffer:array of byte;
//buffer:pointer;
memsize,BufferSize:integer;
byteswritten:cardinal;
ret:boolean;
hDevice_dst:thandle;
dst,src:string;
start:cardinal;
begin
OutputDebugString(pchar('start'));

memsize:=1024*64;BufferSize:=memsize;
ipos:=0;

OpenDialog1.Filter :='VMDK|*.VMDK';
if OpenDialog1.Execute =false then exit;
src:=OpenDialog1.FileName ;

dst:=ChangeFileExt(src,'.dd'); 
{$i-}deletefile(dst);{$i-}

vmdk:=TLibVMDK.create ;
try
if vmdk.libvmdk_open_wide (widestring(src),LIBVMDK_OPEN_READ)=0 then
  begin
    if vmdk.libvmdk_open_extent_data_files <>1 then raise exception.Create('Unable to open extent data files');
    mediaSize:=vmdk.libvmdk_get_media_size ;
    pb_img.Max :=mediasize;
    if mediasize >0 then
    begin
      //VirtualAlloc (buffer,memsize,MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
      setlength(buffer,memsize );
      hDevice_dst := CreateFile(pchar(dst), GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CREATE_NEW, 0 , 0);
      start:=GetTickCount ;
      while (lengthRead>0)  do
      begin
      if ipos+BufferSize >mediasize then BufferSize :=mediasize -ipos;
      lengthRead:=vmdk.libvmdk_read_buffer_at_offset (@buffer[0], BufferSize, ipos);
      if lengthRead>0 then
        begin
        ret:=WriteFile (hDevice_dst, buffer[0], lengthRead, byteswritten, nil);
        if (ret=false) or (byteswritten<>lengthRead) then begin showmessage('writefile failed');break;end;
        end;
      ipos:=ipos+BufferSize ;
      pb_img.Position :=ipos;
      end; //while
      closehandle(hDevice_dst);
      StatusBar1.SimpleText := ('done in '+inttostr(GetTickCount -start)+'ms');
      //virtualfree(buffer,memsize ,MEM_RELEASE );
      //fLibEWF.libewf_close; //will be done in the free/destroy
    end//if mediasize >0 then
    else showmessage('libvmdk_get_media_size failed');
    end;//if fLibEWF.libewf_open
finally
FreeAndNil(vmdk);
end;
end;


end.


