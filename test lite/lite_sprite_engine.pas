(*
  🎮 RaySpriteEngine for RayLib™💣

  📫guvacode@gmail.com 🌐https://github.com/GuvaCode

  Inspired in the original SpriteEngine made by DraculaLin👏 for Asphyre
*)
unit lite_sprite_engine;

{$mode ObjFPC}{$H+}

interface

uses
 ray_header, lite_math_2d, Classes, SysUtils;

type
  TBlendingEffect = ( beUndefined = -1, beAlpha, beAdditive, beMultiplied, beAddColors,
  beSubtract, beCustom);

  TTextureFilter = ( tfPoint = 0, tfBilinear, tfTrilinear, tfAnisotropic4, tfAnisotropic8,
  tfAnisotropic16);

  TTextureWrap = (twRepeat=0, twClamp, twMirrorRepeat, twMirrorClamp);

  TMirrorMode = (MrmNormal, MrmX, MrmY, MrmXY);

  TJumpState = (jsNone, jsJumping, jsFalling);

  { TSpriteEngine }
  TSpriteEngine = class
  private
    FWorld: TVector3;
    FCamera: TCamera2D;
    procedure SetCamera(Value: TCamera2D);
    procedure SetWorldX(Value: Single);
    procedure SetWorldY(Value: Single);
  public
    FList: TList;
    FDeadList: TList;

    procedure Draw;
    procedure ClearDeadSprites;
    procedure Move(MoveCount: Double);
    procedure SetZOrder;

    constructor Create;
    destructor Destroy; override;

    property Camera: TCamera2D read FCamera write SetCamera;
    property WorldX: Single read FWorld.X write SetWorldX;
    property WorldY: Single read FWorld.Y write SetWorldY;
  end;

  TPattern = record
    Height, Width: Integer;
  end;

  { TLiteTexture }
  TLiteTexture = class
  public
    Count: Integer;
    TextureName: array of string;
    Texture: array of TTexture2D;
    Pattern: array of TPattern;
    function LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  { TSprite }
  TSprite = class
  private
    FAlpha: Integer;
    FAngleVector: TVector2;
    FAnimated: Boolean;
    FBlendingEffect: TBlendingEffect;
    FBlue: Integer;
    FGreen: Integer;
    FMirrorMode: TMirrorMode;
    FRed: Integer;
    FTextureFilter: TTextureFilter;
    FTextureWrap: TTextureWrap;
    FVector: TVector3;
    FZ: Single;
    FScale: Single;
    FAngle: Single;
    FTexture: TLiteTexture;
    procedure SetAlpha(AValue: Integer);
    procedure SetAngleVector(AValue: TVector2);
    procedure SetBlue(AValue: Integer);
    procedure SetGreen(AValue: Integer);
    procedure SetRed(AValue: Integer);
    procedure SetTexture_Filter(AValue: TTextureFilter);
    procedure SetTexture_Wrap(AValue: TTextureWrap);
  protected
    FEngine: TSpriteEngine;
    FTextureName: string;
    FTextureIndex: Integer;
    procedure SetTextureName(Value: string);
    procedure SetTextureIndex(Value: Integer);
  public
    IsSpriteDead: Boolean;
    ScaleX, ScaleY: Single;
    Visible: Boolean;
    VisibleArea: TRect;
    Pattern: TRect;

    procedure Draw;
    procedure Move(MoveCount: Double); virtual;
    procedure Dead;
    procedure SetOrder(Value: Single);
    procedure SetScale(Value: Single);

    constructor Create(Engine: TSpriteEngine; Texture: TLiteTexture); virtual;
    destructor Destroy; override;

    procedure LookAt(TargetX, TargetY: Single);
    procedure TowardToAngle(Angle, Speed: Single; DoLookAt: Boolean);

    property TextureIndex: Integer read FTextureIndex write SetTextureIndex;
    property TextureName: string read FTextureName write SetTextureName;

    property X: Single read FVector.X write FVector.X;
    property Y: Single read FVector.Y write FVector.Y;
    property Z: Single read FZ write SetOrder;
    property Angle: Single read FAngle write FAngle;
    property Scale: Single read FScale write SetScale;

    property Red: Integer read FRed write SetRed default 255;
    property Green: Integer read FGreen write SetGreen default 255;
    property Blue: Integer read FBlue write SetBlue default 255;
    property Alpha: Integer read FAlpha write SetAlpha default 255;

    property BlendingEffect: TBlendingEffect read FBlendingEffect write FBlendingEffect;
    property TextureFilter: TTextureFilter read FTextureFilter write SetTexture_Filter;
    property TextureWrap: TTextureWrap read FTextureWrap write SetTexture_Wrap;
    property MirrorMode: TMirrorMode read FMirrorMode write FMirrorMode;


    property AngleVectorX: Single read FAngleVector.x write FAngleVector.x;
    property AngleVectorY: Single read FAngleVector.y write FAngleVector.y;
  end;

  { TAnimatedSprite }
  TAnimatedSprite = class(TSprite)
  protected
    FDoAnimated: Boolean;
    FSplited: array of TRect;
    FPatternIndex: Integer;
    FPatternHeight: Integer;
    FPatternWidth: Integer;
    procedure SetPatternHeight(Value: Integer);
    procedure SetPatternWidth(Value: Integer);
  public
    AnimLooped: Boolean;
    AnimStart: Integer;
    AnimCount: Integer;
    AnimSpeed: Single;
    AnimPos: Single;

    PatternCount: Integer;
    PatternDeltaX: Integer;
    PatternDeltaY: Integer;

{    procedure Split;
    procedure Split2;
    procedure Split3;   }

    procedure Draw;
    procedure Move(MoveCount: Double); override;
    procedure DoAnim(Looped: Boolean; Start: Integer; Count: Integer; Speed: Single);

    constructor Create(Engine: TSpriteEngine; Texture: TLiteTexture); override;
    destructor Destroy; override;

    property PatternHeight: Integer read FPatternHeight write SetPatternHeight;
    property PatternWidth: Integer read FPatternWidth write SetPatternWidth;
  end;


implementation

{ TSpriteEngine }
{$Region TSpriteEngine}
procedure TSpriteEngine.SetCamera(Value: TCamera2D);
begin
  FCamera := Value;
end;

procedure TSpriteEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure TSpriteEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure TSpriteEngine.Draw;
var i: Integer;
begin
 for i := 0 to FList.Count - 1 do
  begin
    if TSprite(FList.Items[i]).FAnimated = False then TSprite(FList.Items[i]).Draw
    else TAnimatedSprite(FList.Items[i]).Draw;
  end;
end;

procedure TSpriteEngine.ClearDeadSprites;
var i: Integer;
begin
  for i := 0 to FDeadList.Count - 1 do
   begin
    if FDeadList.Count >= 1 then
    begin
      if TSprite(FDeadList.Items[i]).IsSpriteDead = True then
      TSprite(FDeadList.Items[i]).FEngine.FList.Remove(FDeadList.Items[i]);
    end;
   end;
  FDeadList.Clear;
end;

procedure TSpriteEngine.Move(MoveCount: Double);
var i: Integer;
begin
 for i := 0 to FList.Count - 1 do
  begin
    if TSprite(FList.Items[i]).FAnimated = False then
    TSprite(FList.Items[i]).Move(MoveCount)
    else
    TAnimatedSprite(FList.Items[i]).Move(MoveCount);
  end;
end;

procedure TSpriteEngine.SetZOrder;
var i: Integer; Done: Boolean;
begin
  Done := False;
  repeat
    for i := FList.Count - 1 downto 0 do
    begin
      if i = 0 then
      begin
        Done := True;
        break;
      end;
      if TSprite(FList.Items[i]).Z < TSprite(FList.Items[i - 1]).Z then
      begin
        FList.Move(i, i - 1);
        Break;
      end;
    end;
  until Done;
end;

constructor TSpriteEngine.Create;
begin
   FList := TList.Create;
   FDeadList := TList.Create;
end;

destructor TSpriteEngine.Destroy;
var i: Integer;
begin
  for i := 0 to FList.Count - 1 do TSprite(FList.Items[i]).Destroy;
  FList.Destroy;
  FDeadList.Destroy;
  inherited Destroy;
end;
{$EndRegion}

{ TLiteTexture }
{$Region TLiteTexture}
function TLiteTexture.LoadFromFile(FileName: String; Width, Height: Integer
  ): Boolean;
begin
    if not fileexists(FileName) then
   begin
    Result := False;
    Exit;
   end;

  SetLength(Texture, Count + 1);
  SetLength(TextureName, Count + 1);
  SetLength(Pattern, Count + 1);

  Inc(Count);

  TextureName[Count - 1] := FileName;
  Pattern[Count - 1].Width := Width;
  Pattern[Count - 1].Height := Height;

  Texture[Count - 1] := LoadTexture(Pchar(FileName));
  //tex_SetFrameSize(Texture[Count - 1], Width, Height);
  Result := True;
end;

constructor TLiteTexture.Create;
begin
  //--//---//---
end;

destructor TLiteTexture.Destroy;
var
  i: Integer;
begin

  for i := 0 to Count - 1 do
  begin
    TextureName[i] := Emptystr;
    UnloadTexture(Texture[i]);
    Pattern[i].Height := 0;
    Pattern[i].Width := 0;
  end;

  SetLength(TextureName, 0);
  SetLength(Texture, 0);
  SetLength(Pattern, 0);

  Count := 0;
  inherited Destroy;
end;
{$EndRegion}

{ TSprite }
{$Region TSprite}

procedure TSprite.SetAlpha(AValue: Integer);
begin
  if FAlpha=AValue then Exit;
  FAlpha:=AValue;
end;

procedure TSprite.SetAngleVector(AValue: TVector2);
begin
 //.. if FAngleVector=AValue then Exit;
  FAngleVector:=AValue;
end;

procedure TSprite.SetBlue(AValue: Integer);
begin
  if FBlue=AValue then Exit;
  FBlue:=AValue;
end;

procedure TSprite.SetGreen(AValue: Integer);
begin
  if FGreen=AValue then Exit;
  FGreen:=AValue;
end;

procedure TSprite.SetRed(AValue: Integer);
begin
  if FRed=AValue then Exit;
  FRed:=AValue;
end;

procedure TSprite.SetTexture_Filter(AValue: TTextureFilter);
begin
  FTextureFilter:=AValue;
  SetTextureFilter(FTexture.Texture[TextureIndex],Ord(FTextureFilter));
end;

procedure TSprite.SetTexture_Wrap(AValue: TTextureWrap);
begin
  FTextureWrap:=AValue;
  SetTextureWrap(FTexture.Texture[TextureIndex],Ord(FTextureWrap));
end;

procedure TSprite.SetTextureName(Value: string);
var i: Integer;
begin
  FTextureName := Value;
  for i := 0 to Length(FTexture.TextureName) - 1 do
  begin
    if ansilowercase(FTextureName) = ansilowercase(FTexture.TextureName[i]) then
    begin
      TextureIndex := i;
      Pattern.Right := FTexture.Pattern[i].Height;
      Pattern.Bottom := FTexture.Pattern[i].Width;
      Exit;
    end;
  end;
  TextureIndex := -1;
end;

procedure TSprite.SetTextureIndex(Value: Integer);
begin
  FTextureIndex := Value;
  Pattern.Right := FTexture.Pattern[FTextureIndex].Height;
  Pattern.Bottom := FTexture.Pattern[FTextureIndex].Width;
end;

procedure TSprite.Draw;
var
  Source: TRectangle;
  Dest: TRectangle;

begin

  if not TextureIndex >= 0 then Exit;

   if Assigned(FEngine) then
    begin //toDo visible Area;

    if  (X >  (FEngine.WorldX) + VisibleArea.Left) and
    (X + Pattern.Right < (FEngine.WorldX) + VisibleArea.Right + 300) and
    (Y > (FEngine.WorldY) + VisibleArea.Top) and
    (Y + Pattern.Bottom < (FEngine.WorldY) + VisibleArea.Bottom + 300) then
    begin


   // SetTextureWrap(FTexture.Texture[TextureIndex],TEXTURE_WRAP_MIRROR_REPEAT);
 //   SetTextureFilter(FTexture.Texture[TextureIndex],TEXTURE_FILTER_BILINEAR);

    BeginBlendMode(Ord(FBlendingEffect));


   case MirrorMode of
    mrmNormal:RectangleSet(@Source, 0, 0, FTexture.Texture[TextureIndex].width, FTexture.Texture[TextureIndex].height);
    mrmX:     RectangleSet(@Source, 0, 0, -FTexture.Texture[TextureIndex].width, FTexture.Texture[TextureIndex].height);
    mrmY:     RectangleSet(@Source, 0, 0, FTexture.Texture[TextureIndex].width, -FTexture.Texture[TextureIndex].height);
    mrmXY:    RectangleSet(@Source, 0, 0, -FTexture.Texture[TextureIndex].width, -FTexture.Texture[TextureIndex].height);
   end;


     RectangleSet(@Dest, FEngine.FCamera.target.x + X,    //X + FWorldX + Offset.X - FEngine.FWorldX,
                         FEngine.FCamera.target.y + Y,    //FY + FWorldY + Offset.Y - FEngine.FWorldY,
                         FTexture.Texture[TextureIndex].width  * ScaleX,
                         FTexture.Texture[TextureIndex].height * ScaleY);



     DrawTexturePro(FTexture.Texture[TextureIndex],
     Source, Dest, Vector2Create(FAngleVector.x*ScaleX,FAngleVector.y*ScaleY),
     {FAngleVector,} FAngle, ColorCreate(Fred,FGreen,FBlue,FAlpha)); //todo

     EndBlendMode;
    end;

    end;
end;

procedure TSprite.Move(MoveCount: Double);
begin

 //--//--//--//
end;

procedure TSprite.Dead;
begin
    if IsSpriteDead = False then
  begin
    IsSpriteDead := True;
    FEngine.FDeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure TSprite.SetOrder(Value: Single);
begin
  if FZ <> Value then FZ := Value;
  FEngine.SetZOrder;
end;

procedure TSprite.SetScale(Value: Single);
begin
  FScale := Value;
  ScaleX := FScale;
  ScaleY := FScale;
end;

constructor TSprite.Create(Engine: TSpriteEngine; Texture: TLiteTexture);
begin
  FAnimated := False;
  FEngine := Engine;
  FEngine.FList.Add(Self);
  FTexture := Texture;

  Pattern.Left := 0;
  Pattern.Top := 0;

  Blue := 255;
  Green := 255;
  Red := 255;
  Alpha := 255;

  ScaleX := 1.0;
  ScaleY := 1.0;

  Visible := True; // Displaymode Width/Height
  VisibleArea := Rect(- 600 , - 600, GetScreenWidth , GetScreenHeight);

  MirrorMode:=mrmNormal;

  FAngleVector:=Vector2Create(0,0);
  FTextureFilter:=tfBilinear;
  FTextureWrap:= twClamp;
//  TTextureWrap = (twRepeat=0, twClamp, twMirrorRepeat, twMirrorClamp);
end;

destructor TSprite.Destroy;
begin
  inherited Destroy;
end;

procedure TSprite.LookAt(TargetX, TargetY: Single);
begin
  Angle:=m_Angle(Self.X,Self.Y,TargetX, TargetY) - 90;
end;

procedure TSprite.TowardToAngle(Angle, Speed: Single; DoLookAt: Boolean);
begin
  if DoLookAt then FAngle := Angle;
  X := X + m_Sin(Round(Angle)) * Speed;
  Y := Y - m_Cos(Round(Angle)) * Speed;
end;

{$EndRegion}

{ TAnimatedSprite }
{$Region TAnimatedSprite}
procedure TAnimatedSprite.SetPatternHeight(Value: Integer);
begin

end;

procedure TAnimatedSprite.SetPatternWidth(Value: Integer);
begin

end;

procedure TAnimatedSprite.Draw;
begin

end;

procedure TAnimatedSprite.Move(MoveCount: Double);
begin
  inherited Move(MoveCount);
end;

procedure TAnimatedSprite.DoAnim(Looped: Boolean; Start: Integer;
  Count: Integer; Speed: Single);
begin

end;

constructor TAnimatedSprite.Create(Engine: TSpriteEngine; Texture: TLiteTexture
  );
begin
  inherited Create(Engine, Texture);
end;

destructor TAnimatedSprite.Destroy;
begin
  inherited Destroy;
end;
{$EndRegion}


end.

