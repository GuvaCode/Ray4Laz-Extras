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
  {$Region Enum}
  TBlendingEffect = ( beUndefined = -1, beAlpha, beAdditive, beMultiplied, beAddColors,
  beSubtract, beCustom);

  TTextureFilter = ( tfPoint = 0, tfBilinear, tfTrilinear, tfAnisotropic4, tfAnisotropic8,
  tfAnisotropic16);

  TTextureWrap = (twRepeat=0, twClamp, twMirrorRepeat, twMirrorClamp);

  TMirrorMode = (MmNormal, MmX, MmY, MmXY);

  TAnimPlayMode = (pmForward, pmBackward);

  TJumpState = (jsNone, jsJumping, jsFalling);
  {$EndRegion}

  { TSpriteEngine }
  TSpriteEngine = class
  private
    FCameraOffset: TVector2;
    FCameraRotation: Single;
    FCameraTarget: TVector2;
    FCameraZoom: Single;
    FVisibleHeight: Integer;
    FVisibleWidth: Integer;
    FWorld: TVector3;
    FCamera: TCamera2D;
    procedure SetCameraOffset(AValue: TVector2);
    procedure SetCameraRotation(AValue: Single);
    procedure SetCameraTarget(AValue: TVector2);
    procedure SetCameraZoom(AValue: Single);
    procedure SetWorldX(Value: Single);
    procedure SetWorldY(Value: Single);
  protected
    FList: TList;
    FDeadList: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw;
    procedure ClearDeadSprites;
    procedure Move(MoveCount: Double);
    procedure SetZOrder;
    property Camera: TCamera2D read FCamera;
    property CameraTarget: TVector2 read FCameraTarget write SetCameraTarget;
    property CameraOffset: TVector2 read FCameraOffset write SetCameraOffset;
    property CameraZoom:    Single read FCameraZoom write SetCameraZoom default 1.0;
    property CameraRotation:Single read FCameraRotation write SetCameraRotation;
    property VisibleWidth: Integer read FVisibleWidth write FVisibleWidth;
    property VisibleHeight: Integer read FVisibleHeight write FVisibleHeight;
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
    Pattern: TRectangle;
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
  private
    FAnimCount: Integer;
    FAnimEnded: Boolean;
    FAnimLooped: Boolean;
    FAnimPlayMode: TAnimPlayMode;
    FAnimPos: Single;
    FAnimSpeed: Single;
    FAnimStart: Integer;
    FDoAnimate: Boolean;
    FPatternCount: Integer;
    procedure SetAnimStart(AValue: Integer);
    function SetPatternRec(ATexture: TTexture; PatternIndex, PatternWidth, PatternHeight: Integer): TRectangle;
  protected
    FPatternIndex: Integer;
    FPatternHeight: Integer;
    FPatternWidth: Integer;
    procedure SetPatternHeight(Value: Integer);
    procedure SetPatternWidth(Value: Integer);
  public
    procedure Draw;
    procedure Move(MoveCount: Double); override;
    procedure DoAnim(Looped: Boolean; Start: Integer; Count: Integer; Speed: Single; PlayMode: TAnimPlayMode = pmForward);
    procedure SetPattern(APatternWidth, APatternHeight: Integer);
    constructor Create(Engine: TSpriteEngine; Texture: TLiteTexture); override;
    destructor Destroy; override;

    property PatternHeight: Integer read FPatternHeight write SetPatternHeight;
    property PatternWidth: Integer read FPatternWidth write SetPatternWidth;
    property PatternCount: Integer read FPatternCount write FPatternCount;

    property AnimPos    : Single read FAnimPos write FAnimPos;
    property AnimStart  : Integer read FAnimStart write SetAnimStart;
    property AnimCount  : Integer read FAnimCount write FAnimCount;
    property AnimSpeed  : Single read FAnimSpeed write FAnimSpeed;
    property AnimLooped : Boolean read FAnimLooped write FAnimLooped;
    property DoAnimate  : Boolean read FDoAnimate write FDoAnimate;
    property AnimPlayMode: TAnimPlayMode read FAnimPlayMode write FAnimPlayMode;
  end;


implementation

{ TSpriteEngine }
{$Region TSpriteEngine}
procedure TSpriteEngine.SetCameraTarget(AValue: TVector2);
begin
  FCameraTarget:=AValue;
  FCamera.target:=FCameraTarget;
end;

procedure TSpriteEngine.SetCameraZoom(AValue: Single);
begin
  FCameraZoom:=AValue;
  FCamera.zoom:=FCameraZoom;
end;

procedure TSpriteEngine.SetCameraOffset(AValue: TVector2);
begin
  FCameraOffset:=AValue;
  FCamera.offset:=FCameraOffset;
end;

procedure TSpriteEngine.SetCameraRotation(AValue: Single);
begin
  FCameraRotation:=AValue;
  FCamera.rotation:=FCameraRotation;
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
   FVisibleWidth:=GetScreenWidth;
   FVisibleHeight:=GetScreenHeight;
   SetCameraZoom(1.0);
   SetCameraOffset(Vector2Create(0,0));
   SetCameraTarget(Vector2Create(0,0));
   SetCameraRotation(0.0);
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

  TextureName[Count - 1] := ChangeFileExt(ExtractFileName(FileName), '');
  Pattern[Count - 1].Width := Width;
  Pattern[Count - 1].Height := Height;

  Texture[Count - 1] := LoadTexture(Pchar(FileName));

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
      Pattern.height := FTexture.Pattern[i].Height;
      Pattern.width := FTexture.Pattern[i].Width;
      Exit;
    end;
  end;
  TextureIndex := -1;
end;

procedure TSprite.SetTextureIndex(Value: Integer);
begin
  FTextureIndex := Value;
  Pattern.height := FTexture.Pattern[FTextureIndex].Height;
  Pattern.width := FTexture.Pattern[FTextureIndex].Width;
end;

procedure TSprite.Draw;
var
  Source: TRectangle;
  Dest: TRectangle;
begin
  if not TextureIndex >= 0 then Exit;
  if Assigned(FEngine) then
  begin
     if (X + FEngine.Camera.offset.X  > FEngine.WorldX - (FTexture.Texture[TextureIndex].width + FEngine.Camera.offset.X) ) and
        (Y + FEngine.Camera.offset.Y  > FEngine.WorldY - (FTexture.Texture[TextureIndex].height + FEngine.Camera.offset.Y) ) and
        (X + FEngine.Camera.offset.X  < FEngine.WorldX + (FEngine.VisibleWidth+ FEngine.Camera.offset.X)) and
        (Y + FEngine.Camera.offset.Y  < FEngine.WorldY + (FEngine.VisibleHeight+ FEngine.Camera.offset.Y))
   then
    begin
     BeginBlendMode(Ord(FBlendingEffect));
     case MirrorMode of
       mmNormal:RectangleSet(@Source, 0, 0, FTexture.Texture[TextureIndex].width, FTexture.Texture[TextureIndex].height);
       mmX:     RectangleSet(@Source, 0, 0, -FTexture.Texture[TextureIndex].width, FTexture.Texture[TextureIndex].height);
       mmY:     RectangleSet(@Source, 0, 0, FTexture.Texture[TextureIndex].width, -FTexture.Texture[TextureIndex].height);
       mmXY:    RectangleSet(@Source, 0, 0, -FTexture.Texture[TextureIndex].width, -FTexture.Texture[TextureIndex].height);
     end;

     RectangleSet(@Dest, FEngine.FCamera.target.x + X,    //X + FWorldX + Offset.X - FEngine.FWorldX,
                         FEngine.FCamera.target.y + Y,    //FY + FWorldY + Offset.Y - FEngine.FWorldY,
                         FTexture.Texture[TextureIndex].width  * ScaleX,
                         FTexture.Texture[TextureIndex].height * ScaleY);

     DrawTexturePro(FTexture.Texture[TextureIndex],
     Source, Dest, Vector2Create(FAngleVector.x*ScaleX,FAngleVector.y*ScaleY), //<{FAngleVector,}
     FAngle, ColorCreate(Fred,FGreen,FBlue,FAlpha));

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

  Pattern.width := 0;
  Pattern.height := 0;

  Blue := 255;
  Green := 255;
  Red := 255;
  Alpha := 255;

  ScaleX := 1.0;
  ScaleY := 1.0;

  Visible := True; // Displaymode Width/Height

  MirrorMode:=mmNormal;

  FAngleVector:=Vector2Create(0,0);
  FTextureFilter:=tfBilinear;
  FTextureWrap:= twClamp;

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

procedure TAnimatedSprite.SetAnimStart(AValue: Integer);
begin
  if FAnimStart=AValue then Exit;
  FAnimStart:=AValue;
end;

function TAnimatedSprite.SetPatternRec(ATexture: TTexture; PatternIndex,
  PatternWidth, PatternHeight: Integer): TRectangle;
var FTexWidth, FTexHeight, ColCount, RowCount, FFPatternIndex:integer;
    Left,Right,Top,Bottom,FFWidth,FFHeight,XX1,YY1,XX2,YY2:integer;
begin
  FTexWidth := ATexture.Width;
   FTexHeight := ATexture.Height;
   ColCount := FTexWidth div PatternWidth;
   RowCount := FTexHeight div PatternHeight;
   FFPatternIndex := PatternIndex;
  if FFPatternIndex < 0 then
    FFPatternIndex := 0;
  if FFPatternIndex >= RowCount * ColCount then
    FFPatternIndex := RowCount * ColCount - 1;
   Left := (FFPatternIndex mod ColCount) * PatternWidth;
   Right := Left + PatternWidth;
   Top := (FFPatternIndex div ColCount) * PatternHeight;
   Bottom := Top + PatternHeight;
   FFWidth := Right - Left;
   FFHeight := Bottom - Top;
   XX1 := Left;
   YY1 := Top;
   XX2 := (Left + FFWidth);
   YY2 := (Top + FFHeight);
   Result:=RectangleCreate(Round(XX1), Round(YY1), Round(XX2), Round(YY2));
end;

procedure TAnimatedSprite.SetPatternHeight(Value: Integer);
begin
  FPatternHeight := Value;
  Pattern.height := Value;
end;

procedure TAnimatedSprite.SetPatternWidth(Value: Integer);
begin
  FPatternWidth := Value;
  Pattern.width := Value;
end;

procedure TAnimatedSprite.Draw;
var
  Dest: TRectangle;
  frameRec:TRectangle;
begin
  if not TextureIndex >= 0 then Exit;

   if Assigned(FEngine) then
    begin
     if (X + FEngine.Camera.offset.X  > FEngine.WorldX - (PatternWidth + FEngine.Camera.offset.X) ) and
        (Y + FEngine.Camera.offset.Y  > FEngine.WorldY - (PatternHeight + FEngine.Camera.offset.Y) ) and
        (X + FEngine.Camera.offset.X  < FEngine.WorldX + (FEngine.VisibleWidth+ FEngine.Camera.offset.X)) and
        (Y + FEngine.Camera.offset.Y  < FEngine.WorldY + (FEngine.VisibleHeight+ FEngine.Camera.offset.Y))
  then
   begin
    BeginBlendMode(Ord(FBlendingEffect));

    framerec:= SetPatternRec(FTexture.Texture[TextureIndex], FPatternIndex,Trunc(FPatternWidth),Trunc(FPatternHeight));
    framerec.width:=FPatternWidth;
    framerec.height:=FPatternHeight;

    case MirrorMode of
        mmNormal:RectangleSet(@frameRec, framerec.x, framerec.y, Self.PatternWidth, Self.PatternHeight);
        mmX:     RectangleSet(@frameRec, framerec.x, framerec.y,-Self.PatternWidth, Self.PatternHeight);
        mmY:     RectangleSet(@frameRec, framerec.x, framerec.y, Self.PatternWidth,-Self.PatternHeight);
        mmXY:    RectangleSet(@frameRec, framerec.x, framerec.y, -Self.PatternWidth,-Self.PatternHeight);
       end;


      RectangleSet(@Dest, FEngine.FCamera.target.x + X,
                          FEngine.FCamera.target.y + Y,
                          Self.PatternWidth  * ScaleX,
                          Self.PatternHeight * ScaleY);


       DrawTexturePro(FTexture.Texture[TextureIndex],
       frameRec, Dest, Vector2Create(FAngleVector.x*ScaleX,FAngleVector.y*ScaleY),
       FAngle, ColorCreate(FRed,FGreen,FBlue,FAlpha));

      EndBlendMode;
    end;
  end;
end;

procedure TAnimatedSprite.Move(MoveCount: Double);
begin
  if not FDoAnimate then Exit;

  case FAnimPlayMode of

   pmForward:
    begin
      FAnimPos := FAnimPos + FAnimSpeed * MoveCount;
      if (FAnimPos > FAnimStart + FAnimCount ) then
       begin
        if (Trunc(FAnimPos)) = FAnimStart + FAnimCount then FAnimEnded := True;
        if FAnimLooped then FAnimPos := FAnimStart
         else
          begin
            FAnimPos := FAnimStart + FAnimCount-1 ;
            FDoAnimate := False;
          end;
       end;
    end;

   pmBackward:
    begin
     FAnimPos := FAnimPos - FAnimSpeed * MoveCount;
     if (FAnimPos < FAnimStart) then
     if FAnimLooped then FAnimPos := FAnimStart + FAnimCount - 1
     else
      begin
        FAnimPos := FAnimStart;
        FDoAnimate := False;
      end;
    end;

   end;
    FPatternIndex := Trunc(FAnimPos);
end;

procedure TAnimatedSprite.DoAnim(Looped: Boolean; Start: Integer;
  Count: Integer; Speed: Single; PlayMode: TAnimPlayMode);
begin
  FAnimStart  := Start;
  FAnimCount  := Count;
  FAnimSpeed  := Speed;
  FAnimLooped := Looped;
  FAnimPlayMode:= PlayMode;
end;

procedure TAnimatedSprite.SetPattern(APatternWidth, APatternHeight: Integer);
var  ColCount,RowCount: integer;
begin
  FPatternWidth := APatternWidth;
  FPatternHeight := APatternHeight;
  ColCount := FTexture.Texture[TextureIndex].width div FPatternWidth;
  RowCount := FTexture.Texture[TextureIndex].height div FPatternHeight;
  PatternCount := (ColCount * RowCount) - 1;
end;

constructor TAnimatedSprite.Create(Engine: TSpriteEngine; Texture: TLiteTexture);
begin
  inherited Create(Engine, Texture);
  FAnimated := True;
end;

destructor TAnimatedSprite.Destroy;
begin
  inherited Destroy;
end;
{$EndRegion}


end.

