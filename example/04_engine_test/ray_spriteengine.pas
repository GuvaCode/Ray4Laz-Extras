unit ray_SpriteEngine;

{$mode objfpc}{$H+}

interface

uses
  ray_header;

type
  RayCSprite2D  = class;
  RayCSEngine2D = class;

  { RayCSEngine2D }

  RayCSEngine2D = class
  protected
    FCount : Integer;
    FList  : array of rayCSprite2D;

    procedure SortByLayer( iLo, iHi : Integer );
    procedure SortByID( iLo, iHi : Integer );

    function  GetSprite( ID : Integer ) : RayCSprite2D;
    procedure SetSprite( ID : Integer; Sprite : RayCSprite2D );
  public
    destructor Destroy; override;

    function  AddSprite : Integer; overload; virtual;
    function  AddSprite( Texture : TTexture2D; Layer : Integer ) : RayCSprite2D; overload; virtual;
    procedure AddSprite( Sprite  : RayCSprite2D; Layer : Integer ); overload; virtual;
    procedure DelSprite( ID : Integer ); virtual;
    procedure ClearAll; virtual;

    procedure Draw; virtual;
    procedure Proc; virtual;

    property Count: Integer read FCount;
    property List[ID : Integer]: RayCSprite2D read GetSprite write SetSprite;
  end;

  { RayCSprite2D }

  RayCSprite2D = class
  protected
  public
    ID      : Integer;
    Manager : RayCSEngine2D;
    Texture : TTexture2D;
    Kill    : Boolean;
    Layer   : Integer;
    X, Y    : Single;
    W, H    : Single;
    Angle   : Single;
    Frame   : Single;
    Alpha   : Integer;
    FxFlags : LongWord;

    FrameSize : TVector2;
    Origin    : TVector2;
    //frame2    : integer;
    maxFrame  : integer;
    framesWide: integer;

    constructor Create( _Manager : RayCSEngine2D; _ID : Integer ); virtual;
    destructor  Destroy; override;

    procedure OnInit( _Texture : TTexture2D; _Layer : Integer ); virtual;
    procedure OnDraw; virtual;
    procedure OnProc; virtual;
    procedure OnFree; virtual;
  end;

implementation

{ RayCSEngine2D }

procedure RayCSEngine2D.SortByLayer(iLo, iHi: Integer);
var
    lo, hi, mid : Integer;
    t : RayCSprite2D;
begin
  lo   := iLo;
  hi   := iHi;
  mid  := FList[ ( lo + hi ) shr 1 ].Layer;

  repeat
    while FList[ lo ].Layer < mid do INC( lo );
    while FList[ hi ].Layer > mid do DEC( hi );
    if lo <= hi then
      begin
        t           := FList[ lo ];
        FList[ lo ] := FList[ hi ];
        FList[ hi ] := t;
        INC( lo );
        DEC( hi );
      end;
  until lo > hi;

  if hi > iLo Then SortByLayer( iLo, hi );
  if lo < iHi Then SortByLayer( lo, iHi );

end;

procedure RayCSEngine2D.SortByID(iLo, iHi: Integer);
var
  lo, hi, mid : Integer;
  t : RayCSprite2D;
begin
lo   := iLo;
hi   := iHi;
mid  := FList[ ( lo + hi ) shr 1 ].ID;

repeat
  while FList[ lo ].ID < mid do INC( lo );
  while FList[ hi ].ID > mid do DEC( hi );
  if Lo <= Hi then
    begin
      t           := FList[ lo ];
      FList[ lo ] := FList[ hi ];
      FList[ hi ] := t;
      INC( lo );
      DEC( hi );
    end;
until lo > hi;

if hi > iLo Then SortByID( iLo, hi );
if lo < iHi Then SortByID( lo, iHi );

end;

function RayCSEngine2D.GetSprite(ID: Integer): RayCSprite2D;
begin
  Result := FList[ ID ];
end;

procedure RayCSEngine2D.SetSprite(ID: Integer; Sprite: RayCSprite2D);
begin
  FList[ ID ] := Sprite;
end;

destructor RayCSEngine2D.Destroy;
begin
  ClearAll();
end;

function RayCSEngine2D.AddSprite: Integer;
begin
  if FCount + 1 > Length( FList ) Then
    SetLength( FList, FCount + 16384 );
  Result := FCount;
  INC( FCount );
end;

function RayCSEngine2D.AddSprite(Texture: TTexture2D; Layer: Integer): RayCSprite2D;
var id : Integer;
begin
id := AddSprite();
FList[ id ] := RayCSprite2D.Create( Self, id );
Result := FList[ id ];
Result.OnInit( Texture, Layer );
end;

procedure RayCSEngine2D.AddSprite(Sprite: RayCSprite2D; Layer: Integer);
var  id : Integer;
begin
if not Assigned( Sprite ) Then exit;
id := AddSprite();
FList[ id ]         := Sprite;
FList[ id ].Manager := Self;
FList[ id ].ID      := id;
FList[ id ].OnInit( Sprite.Texture, Layer );
end;

procedure RayCSEngine2D.DelSprite(ID: Integer);
var
  i : Integer;
begin
if ( ID < 0 ) or ( ID > FCount - 1 ) or ( FCount = 0 ) Then exit;

FList[ ID ].Free;

for i := ID to FCount - 2 do
  begin
    FList[ i ]    := FList[ i + 1 ];
    FList[ i ].ID := i;
  end;

DEC( FCount );

end;

procedure RayCSEngine2D.ClearAll;
var
  i : Integer;
begin
for i := 0 to FCount - 1 do
  FList[ i ].Destroy();
SetLength( FList, 0 );
FCount := 0;

end;

procedure RayCSEngine2D.Draw;
var
   i : Integer;
   s : RayCSprite2D;
begin
 i := 0;
 while i < FCount do
   begin
     s := FList[ i ];
     s.OnDraw();

     if s.Kill Then
       DelSprite( s.ID )
     else
       INC( i );
   end;

end;

procedure RayCSEngine2D.Proc;
var
  i, a, b, l : Integer;
  s          : RayCSprite2D;
begin
i := 0;
while i < FCount do
  begin
    s := FList[ i ];
    s.OnProc();

    if s.Kill Then
      DelSprite( s.ID )
    else
      INC( i );
  end;

if FCount > 1 Then
  begin
    l := 0;
    for i := 0 to FCount - 1 do
      begin
        s := FList[ i ];
        if s.Layer > l Then l := s.Layer;
        if s.Layer < l Then
          begin
            SortByLayer( 0, FCount - 1 );
            // TODO: provide parameter for enabling/disabling stable sorting
            l := FList[ 0 ].Layer;
            a := 0;
            for b := 0 to FCount - 1 do
              begin
                s := FList[ b ];
                if ( l <> s.Layer ) Then
                  begin
                    SortByID( a, b - 1 );
                    a := b;
                    l := s.Layer;
                  end;
                if b = FCount - 1 Then
                  SortByID( a, b );
              end;
            for a := 0 to FCount - 1 do
              FList[ a ].ID := a;
            break;
          end;
      end;
  end;

end;

{ RayCSprite2D }

constructor RayCSprite2D.Create(_Manager: RayCSEngine2D; _ID: Integer);
var
  nilTex:TTexture2D;
begin
  Manager := _Manager;
  ID      := _ID;
  nilTex.height:=128;
  nilTex.width:=128;
  OnInit( nilTex, 0 );   //todo
//  OnInit( nil, 0 );   //todo
end;

destructor RayCSprite2D.Destroy;
begin
  OnFree();
end;

procedure RayCSprite2D.OnInit(_Texture: TTexture2D; _Layer: Integer);
begin
  Texture := _Texture;
  Layer   := _Layer;
  X       := 0;
  Y       := 0;
 // if Assigned( Texture.id ) Then
   if (Texture.width) or (Texture.height) > 0 then
 begin
    //  W := Round( ( Texture.FramesCoord[ 1, 1 ].X - Texture.FramesCoord[ 1, 0 ].X ) * Texture.Width / Texture.U );
    //  H := Round( ( Texture.FramesCoord[ 1, 0 ].Y - Texture.FramesCoord[ 1, 2 ].Y ) * Texture.Height / Texture.V );
       // W:= Texture.width;
       // H:= Texture.height;
    end else
      begin
      //  W := 0;
      //  H := 0;
      end;
  Angle   := 0;
  Frame   := 1;
  Alpha   := 255;
 // FxFlags := FX_BLEND;  // todo todo
end;

procedure RayCSprite2D.OnDraw;
var ox,oy : single;
    scale:single;
begin
  scale:=1;
  ox := (Round(frame) mod framesWide) * frameSize.x;
  oy :=round((frame / framesWide) * frameSize.y);

  DrawTexturePro(Texture,RectangleCreate(ox, oy,frameSize.x,frameSize.y),
      RectangleCreate(x, y, frameSize.x * scale, frameSize.y * scale),
      Vector2Create(origin.x * scale, origin.y * scale),Angle, White);
      // asprite2d_Draw( Texture, X, Y, W, H, Angle, Round( Frame ), Alpha, FxFlags );
end;

procedure RayCSprite2D.OnProc;
begin

end;

procedure RayCSprite2D.OnFree;
begin
end;

end.

