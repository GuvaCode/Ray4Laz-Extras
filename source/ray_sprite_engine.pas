(*
  🎮 RaySpriteEngine for RayLib™💣

  📫guvacode@gmail.com 🌐https://github.com/GuvaCode

  Inspired in the original SpriteEngine made by DraculaLin👏 for Asphyre
*)
unit ray_sprite_engine;

{$mode ObjFPC}{$H+}

interface

uses
 ray_header, ray_math, Classes, SysUtils, math;

type
  {$Region Enum}
  TBlendingEffect = ( beUndefined = -1, beAlpha, beAdditive, beMultiplied, beAddColors,
  beSubtract, beCustom);

  TTextureFilter = ( tfPoint = 0, tfBilinear, tfTrilinear, tfAnisotropic4, tfAnisotropic8,
  tfAnisotropic16);

  TTextureWrap = (twRepeat=0, twClamp, twMirrorRepeat, twMirrorClamp);

  TMirrorMode = (MmNormal, MmX, MmY, MmXY);

  TJumpState = (jsNone, jsJumping, jsFalling);

  TCollideMode = (cmCircle, cmRect, cmCircleRec, cmPolygon);

  {$EndRegion}

  { TSpriteEngine }
  TSpriteEngine = class
  private
    FVisibleHeight: Integer;
    FVisibleWidth: Integer;
    FWorld: TVector2;
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
    property VisibleWidth: Integer read FVisibleWidth write FVisibleWidth;
    property VisibleHeight: Integer read FVisibleHeight write FVisibleHeight;
    property WorldX: Single read FWorld.X write SetWorldX;
    property WorldY: Single read FWorld.Y write SetWorldY;
  end;

  TPattern = record
    Height, Width: Integer;
  end;

  { TGameTexture }
  TGameTexture = class
  public
    Count: Integer;
    TextureName: array of string;
    Texture: array of TTexture2D;
    Pattern: array of TPattern;
    function LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
    function LoadFromFile(FileName: String): Boolean;
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
    FCollideCenter: TVector2;
    FCollideMode: TCollideMode;
    FCollideRadius: Single;
    FCollideRect: TRectangle;
    FCollisioned: Boolean;
    FGreen: Integer;
    FMirrorMode: TMirrorMode;
    FRed: Integer;
    FSpeedX: Single;
    FSpeedY: Single;
    FTextureFilter: TTextureFilter;
    FTextureWrap: TTextureWrap;
    FVector: TVector3;
    FZ: Single;
    FScale: Single;
    FAngle: Single;
    FTexture: TGameTexture;
    procedure SetAlpha(AValue: Integer);
    procedure SetAngleVector(AValue: TVector2);
    procedure SetBlue(AValue: Integer);
    procedure SetGreen(AValue: Integer);
    procedure SetRed(AValue: Integer);
    procedure SetTexture_Filter(AValue: TTextureFilter);
    procedure SetTexture_Wrap(AValue: TTextureWrap);
    procedure SetRotation (const Value: Single);
  protected
    FEngine: TSpriteEngine;
    FTextureName: string;
    FTextureIndex: Integer;
    procedure SetTextureName(Value: string);
    procedure SetTextureIndex(Value: Integer);
    procedure DoCollision(const Sprite: TSprite); virtual;
    procedure Move(MoveCount: Double); virtual;
  public
    IsSpriteDead: Boolean;
    ScaleX, ScaleY: Single;
    Visible: Boolean;
    Pattern: TRectangle;
    procedure Draw;
    procedure Dead;
    procedure SetOrder(Value: Single);
    procedure SetScale(Value: Single);
    procedure Collision(const Other: TSprite); overload; virtual;
    procedure Collision; overload; virtual;

    constructor Create(Engine: TSpriteEngine; Texture: TGameTexture); virtual;
    destructor Destroy; override;

    procedure LookAt(TargetX, TargetY: Single);
    procedure MoveTowards(Target:Tvector2; Distance: Single);

    property TextureIndex: Integer read FTextureIndex write SetTextureIndex;
    property TextureName: string read FTextureName write SetTextureName;
    property X: Single read FVector.X write FVector.X;
    property Y: Single read FVector.Y write FVector.Y;
    property Z: Single read FZ write SetOrder;
    property Angle: Single read FAngle write FAngle;
    property Scale: Single read FScale write SetScale;
    property Red_: Integer read FRed write SetRed default 255;
    property Green_: Integer read FGreen write SetGreen default 255;
    property Blue_: Integer read FBlue write SetBlue default 255;
    property Alpha: Integer read FAlpha write SetAlpha default 255;
    property BlendingEffect: TBlendingEffect read FBlendingEffect write FBlendingEffect;
    property TextureFilter: TTextureFilter read FTextureFilter write SetTexture_Filter;
    property TextureWrap: TTextureWrap read FTextureWrap write SetTexture_Wrap;
    property MirrorMode: TMirrorMode read FMirrorMode write FMirrorMode;
    property AngleVectorX: Single read FAngleVector.x write FAngleVector.x;
    property AngleVectorY: Single read FAngleVector.y write FAngleVector.y;

    property CollideMode: TCollideMode read FCollideMode write FCollideMode;
    property Collisioned: Boolean read FCollisioned write FCollisioned;
    property CollideRect: TRectangle read FCollideRect write FCollideRect;
    property CollideCenter: TVector2 read FCollideCenter write FCollideCenter;
    property CollideRadius: Single read FCollideRadius write FCollideRadius;
    property SpeedX: Single read FSpeedX write FSpeedX;
    property SpeedY: Single read FSpeedY write FSpeedY;

  end;

  { TAnimatedSprite }
  TAnimatedSprite = class(TSprite)
  private
    FAnimCount: Integer;
    FAnimEnded: Boolean;
    FAnimLooped: Boolean;
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
    FOldIndex:Integer;
    procedure SetPatternHeight(Value: Integer);
    procedure SetPatternWidth(Value: Integer);
  public
    function AnimEnded: Boolean;
    procedure Draw;
    procedure Move(MoveCount: Double); override;
    procedure SetAnim(AniStart, AniCount: Integer; AniSpeed: Single; AniLooped:Boolean); overload; virtual;
    procedure SetPattern(APatternWidth, APatternHeight: Integer);
    procedure OnAnimStart; virtual;
    procedure OnAnimEnd; virtual;
    constructor Create(Engine: TSpriteEngine; Texture: TGameTexture); override;
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
  end;


implementation

{ TSpriteEngine }
{$Region TSpriteEngine}
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

{ TGameTexture }
{$Region TGameTexture}
function TGameTexture.LoadFromFile(FileName: String; Width, Height: Integer
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

function TGameTexture.LoadFromFile(FileName: String): Boolean;
begin
  result:=LoadFromFile(FileName,0,0);
end;

constructor TGameTexture.Create;
begin
  //--//---//---
end;

destructor TGameTexture.Destroy;
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

procedure TSprite.SetRotation(const Value: Single);
begin
    if (Fangle <> Value) then
  begin
    Fangle:= Value;

   // TransformRequired:= True;
  end;
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

procedure TSprite.DoCollision(const Sprite: TSprite);
begin
  //
end;

procedure TSprite.Draw;
var
  Source: TRectangle;
  Dest: TRectangle;
begin
  if not TextureIndex >= 0 then Exit;
  if Assigned(FEngine) then
  begin
   {  if (X + FEngine.Camera.offset.X  > FEngine.WorldX - (FTexture.Texture[TextureIndex].width + FEngine.Camera.offset.X) ) and
        (Y + FEngine.Camera.offset.Y  > FEngine.WorldY - (FTexture.Texture[TextureIndex].height + FEngine.Camera.offset.Y) ) and
        (X + FEngine.Camera.offset.X  < FEngine.WorldX + (FEngine.VisibleWidth+ FEngine.Camera.offset.X)) and
        (Y + FEngine.Camera.offset.Y  < FEngine.WorldY + (FEngine.VisibleHeight+ FEngine.Camera.offset.Y)) }

      if (X   > FEngine.WorldX - (FTexture.Texture[TextureIndex].width ) ) and
         (Y   > FEngine.WorldY - (FTexture.Texture[TextureIndex].height ) ) and
         (X   < FEngine.WorldX + (FEngine.VisibleWidth)) and
         (Y   < FEngine.WorldY + (FEngine.VisibleHeight))
   then
    begin
     BeginBlendMode(Ord(FBlendingEffect));
     case MirrorMode of
       mmNormal:RectangleSet(@Source, 0, 0, FTexture.Texture[TextureIndex].width, FTexture.Texture[TextureIndex].height);
       mmX:     RectangleSet(@Source, 0, 0, -FTexture.Texture[TextureIndex].width, FTexture.Texture[TextureIndex].height);
       mmY:     RectangleSet(@Source, 0, 0, FTexture.Texture[TextureIndex].width, -FTexture.Texture[TextureIndex].height);
       mmXY:    RectangleSet(@Source, 0, 0, -FTexture.Texture[TextureIndex].width, -FTexture.Texture[TextureIndex].height);
     end;

     {RectangleSet(@Dest, FEngine.FCamera.target.x + X,    //X + FWorldX + Offset.X - FEngine.FWorldX,
                         FEngine.FCamera.target.y + Y,    //FY + FWorldY + Offset.Y - FEngine.FWorldY,
                         FTexture.Texture[TextureIndex].width  * ScaleX,
                         FTexture.Texture[TextureIndex].height * ScaleY);}

     RectangleSet(@Dest,  X,    //X + FWorldX + Offset.X - FEngine.FWorldX,
                          Y,    //FY + FWorldY + Offset.Y - FEngine.FWorldY,
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

procedure TSprite.Collision(const Other: TSprite);
var
  //Delta: Real;
  IsCollide: Boolean;
begin
  IsCollide := False;

  if (FCollisioned) and (Other.FCollisioned) and (not IsSpriteDead) and (not Other.IsSpriteDead) then
  begin
    case FCollideMode of
      cmCircle:
        begin
         IsCollide := CheckCollisionCircles(Self.CollideCenter,Self.CollideRadius,Other.CollideCenter,Other.CollideRadius);
        end;
      cmRect:
        begin
          IsCollide:=CheckCollisionRecs(Self.FCollideRect, Other.FCollideRect);
        end;
      cmCircleRec:
        begin
          IsCollide:=CheckCollisionCircleRec(Self.CollideCenter,Self.CollideRadius,Other.CollideRect);
        end;
      cmPolygon:
        begin
          //IsCollide := OverlapPolygon(Self.FCollidePolygon, Other.FCollidePolygon);
        end;
    end;

    if IsCollide then
    begin
      DoCollision(Other);
      Other.DoCollision(Self);
    end;
 end;
end;

procedure TSprite.Collision;
var
  I: Integer;
begin
  if (FEngine <> nil) and (not IsSpriteDead) and (Collisioned) then
  begin
   for i := 0 to FEngine.FList.Count - 1 do Collision(TSprite(FEngine.FList.Items[i]));
  end;
end;

constructor TSprite.Create(Engine: TSpriteEngine; Texture: TGameTexture);
begin
  FAnimated := False;
  FEngine := Engine;
  FEngine.FList.Add(Self);
  FTexture := Texture;

  Pattern.width := 0;
  Pattern.height := 0;

  Blue_ := 255;
  Green_ := 255;
  Red_ := 255;
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
  Angle:=Vector2Angle(Vector2Create(X,Y),Vector2Create(TargetX, TargetY));
end;

procedure TSprite.MoveTowards(Target: Tvector2; Distance: Single);
var posVector:TVector2;
begin
 posVector:=Vector2MoveTowards(Vector2Create(X,Y),Target,Distance);
 x:=   posVector.x ;
 y:=   posVector.y ;
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

function TAnimatedSprite.AnimEnded: Boolean;
begin
    if Trunc(AnimPos) = (AnimStart + AnimCount - 1) then
    Result := True
  else
    Result := False;
end;

procedure TAnimatedSprite.Draw;
var
  Dest: TRectangle;
  frameRec:TRectangle;
begin
  if not TextureIndex >= 0 then Exit;

   if Assigned(FEngine) then
    begin
    { if (X + FEngine.Camera.offset.X  > FEngine.WorldX - (PatternWidth + FEngine.Camera.offset.X) ) and
        (Y + FEngine.Camera.offset.Y  > FEngine.WorldY - (PatternHeight + FEngine.Camera.offset.Y) ) and
        (X + FEngine.Camera.offset.X  < FEngine.WorldX + (FEngine.VisibleWidth+ FEngine.Camera.offset.X)) and
        (Y + FEngine.Camera.offset.Y  < FEngine.WorldY + (FEngine.VisibleHeight+ FEngine.Camera.offset.Y)) }

    if (X   > FEngine.WorldX - PatternWidth ) and
       (Y   > FEngine.WorldY -  PatternHeight  ) and
       (X   < FEngine.WorldX +  FEngine.VisibleWidth) and
       (Y   < FEngine.WorldY +  FEngine.VisibleHeight)
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


      {RectangleSet(@Dest, FEngine.FCamera.target.x + X,
                          FEngine.FCamera.target.y + Y,
                          Self.PatternWidth  * ScaleX,
                          Self.PatternHeight * ScaleY);}

      RectangleSet(@Dest, X,
                          Y,
                          Self.PatternWidth  * ScaleX,
                          Self.PatternHeight * ScaleY);


       DrawTexturePro(FTexture.Texture[TextureIndex],
       frameRec, Dest, Vector2Create(FAngleVector.x*ScaleX,FAngleVector.y*ScaleY),
       FAngle, ColorCreate(FRed,FGreen,FBlue,FAlpha));

       FOldIndex:=FPatternIndex;
       EndBlendMode;

    end;
  end;
end;

procedure TAnimatedSprite.Move(MoveCount: Double);
begin
   inherited Move(MoveCount);

   if not FDoAnimate then Exit;

   if Trunc(FAnimPos)>FAnimCount-1 then FAnimPos:= FAnimStart;
   FAnimPos := FAnimPos + FAnimSpeed * MoveCount;
   if (FAnimPos >= FAnimStart + FAnimCount) then
   begin
    if (Trunc(FAnimPos)) = FAnimStart then OnAnimStart;
    if AnimEnded then OnAnimEnd;
    if FAnimLooped then FAnimPos := FAnimStart
     else
      begin
       FAnimPos := FAnimStart + FAnimCount - 1;
       FDoAnimate := False;
      end;
    end;
    FPatternIndex := Trunc(FAnimPos);
end;

procedure TAnimatedSprite.SetAnim(AniStart, AniCount: Integer;
  AniSpeed: Single; AniLooped: Boolean);
begin
  FAnimStart := AniStart;
  SetAnimStart(AniStart);
  FAnimCount := AniCount;
  FAnimSpeed := AniSpeed;
  FAnimLooped := AniLooped;
  if (FPatternIndex < FAnimStart) or (FPatternIndex >= FAnimCount + FAnimStart) then
  begin
    FPatternIndex := FAnimStart mod FAnimCount;
    FAnimPos := FAnimStart;
  end;
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

procedure TAnimatedSprite.OnAnimStart;
begin

end;

procedure TAnimatedSprite.OnAnimEnd;
begin

end;

constructor TAnimatedSprite.Create(Engine: TSpriteEngine; Texture: TGameTexture);
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

