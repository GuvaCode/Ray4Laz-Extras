unit ray_sprites;

{$mode objfpc}{$H+}
{$WARN 5027 off : Local variable "$1" is assigned but never used}
{$WARN 5024 off : Parameter "$1" not used}
interface

uses ray_header, ray_math, ray_math_ex, classes, sysutils;

type
  TJumpState = (jsNone, jsJumping, jsFalling);
  TFlipState = (fsNormal, fsX , fsY , fsXY);
  TCollideMethod = (cmRectangle, cmCircle, cmPointRec, cmPointCircle, cmPolygon);

  { TRaySpriteEngine }
  TRaySpriteEngine = class
  private
    FWorld: TVector2;
    FDeadList: TList;
    FList: TList;
    procedure SetWorldX(Value: Single);
    procedure SetWorldY(Value: Single);
  public


    procedure Draw();
    procedure ClearDeadSprites;
    procedure Move(MoveCount:Double);
    procedure SetZOrder();
    constructor Create;
    destructor Destroy; override;
    property WorldX: Single read FWorld.X write SetWorldX;
    property WorldY: Single read FWorld.Y write SetWorldY;
  end;

  TPattern = record
    Height, Width: Integer;
  end;

  { TRayGameTexture }
  TRayGameTexture = class
  public
    Count: Integer;
    TextureName: array of string;
    Texture: array of TTexture2D;
    Pattern: array of TPattern;
    function LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
    constructor Create;
    destructor Destroy; override;
   end;

  { TRaySprite }
  TRaySprite = class
  private
    FAnimated: Boolean;
    FCollideMethod: TCollideMethod;
    FCollidePolygon: TRayPolygon;
    FCollidePos: TVector2;
    FCollideRadius: Single;
    FCollideRect: TRectangle;
    FCollisioned: Boolean;
    FShowCollide: Boolean;
    FPositionV: TVector2;
    FZ: Single;
    FScale: Single;
  protected
    FEngine: TRaySpriteEngine;
    FTextureName: string;
    FTextureIndex: Integer;
    procedure SetTextureName(Value: string);
    procedure SetTextureIndex(Value: Integer);
    procedure DoCollision(const Sprite: TRaySprite); virtual;
  public
    FTexture: TRayGameTexture;
    FlipState : TFlipState;
    Alpha: Byte;
    Angle: Single;
    IsSpriteDead: Boolean;
    DrawMode: Integer;
    Visible: Boolean;
    Pattern: TNPatchInfo;
    procedure Draw();
    procedure Move(MoveCount: Double); virtual;
    procedure Dead();
    procedure SetOrder(Value: Single);
    procedure SetScale(Value: Single);
    procedure Collision(const Other: TRaySprite); overload; virtual;
    procedure Collision; overload; virtual;
    constructor Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture); virtual;
    destructor Destroy; override;
    property TextureIndex: Integer read FTextureIndex write SetTextureIndex;
    property TextureName: string read FTextureName write SetTextureName;
    property X: Single read FPositionV.X write FPositionV.X;
    property Y: Single read FPositionV.Y write FPositionV.Y;
    property Z: Single read FZ write SetOrder;
    property Scale: Single read FScale write SetScale;
    property Collisioned: Boolean read FCollisioned write FCollisioned;
    property CollideMethod: TCollideMethod read FCollideMethod write FCollideMethod;
    property CollidePos: TVector2 read FCollidePos write FCollidePos;
    property CollideRect: TRectangle read FCollideRect write FCollideRect;
    property CollideRadius: Single read FCollideRadius write FCollideRadius;
    property CollidePolygon: TRayPolygon read FCollidePolygon write FCollidePolygon;
    property ShowCollide: Boolean read FShowCollide write FShowCollide;
  end;


  { TRayAnimatedSprite }
  TRayAnimatedSprite = class(TRaySprite)
  protected
    FDoAnimated: Boolean;
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

    currentFrame:integer;
    currentLine: integer;
    framesCounter: integer;

    procedure Draw();
    procedure Move(MoveCount: Double); override;

    procedure DoAnim(Looped: Boolean; Start: Integer; Count: Integer; Speed: Single);

    constructor Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture); override;
    destructor Destroy; override;

    property PatternHeight: Integer read FPatternHeight write SetPatternHeight;
    property PatternWidth: Integer read FPatternWidth write SetPatternWidth;
  end;

   const ModuleName = 'RAY_SPRITES: ';

implementation

{ TRayAnimatedSprite }
procedure TRayAnimatedSprite.SetPatternHeight(Value: Integer);
begin
  FPatternHeight := Value;
  Pattern.Bottom := Value;
end;

procedure TRayAnimatedSprite.SetPatternWidth(Value: Integer);
begin
  FPatternWidth := Value;
  Pattern.Right := Value;
end;


procedure TRayAnimatedSprite.Draw();
var
     FramesPerLine, NumLines,i: integer;
     Position:TVector2;
     frameRec,Dest:TRectangle;
     AlphaColor:TColor;
begin
     FramesPerLine:=Ftexture.Texture[FTextureIndex].width div FTexture.Pattern[FTextureIndex].Width;//Ширина прямоугольника спрайта в один кадр
     NumLines:=Ftexture.Texture[FTextureIndex].height div FTexture.Pattern[FTextureIndex].Height;//Высота прямоугольника одного кадра спрайта

    if (TextureIndex  <> -1) and (Assigned(FEngine)) then
    begin
     if Visible then
      begin
       if FShowCollide then
           //DrawCollide
           case FCollideMethod of
             cmRectangle:
               DrawRectangleRec(Self.CollideRect,RED);
             cmCircle:
               DrawCircleV(Self.CollidePos ,Self.CollideRadius,RED);
             cmPolygon:
               for i:=0 to Length(FCollidePolygon) -1 do DrawPixelV(FCollidePolygon[i],RED);
            end;

         case FlipState of
            fsNormal :
              RectangleSet(@frameRec,X,Y,FTexture.Pattern[FTextureIndex].Width,FTexture.Pattern[FTextureIndex].Height);
            fsX:
              RectangleSet(@frameRec,X,Y,-FTexture.Pattern[FTextureIndex].Width,FTexture.Pattern[FTextureIndex].Height);
            fsY:
              RectangleSet(@frameRec,X,Y,FTexture.Pattern[FTextureIndex].Width,-FTexture.Pattern[FTextureIndex].Height);
            fsXY:
              RectangleSet(@frameRec,X,Y,-FTexture.Pattern[FTextureIndex].Width,-FTexture.Pattern[FTextureIndex].Height);
           end;

         frameRec.x := Trunc(AnimPos)*Ftexture.Texture[FTextureIndex].width/FramesPerLine;
         frameRec.y := FTexture.Pattern[FTextureIndex].Height * Trunc( AnimPos / NumLines);

         RectangleSet(@Dest,X,Y,FTexture.Pattern[FTextureIndex].Width*Scale, FTexture.Pattern[FTextureIndex].Height*Scale);

         AlphaColor:=White; AlphaColor.a:=Alpha; Vector2Set(@Position,0,0);

         DrawTexturePro(FTexture.Texture[FTextureIndex], frameRec, Dest , position ,Angle ,AlphaColor);
      end;
    end;
end;

procedure TRayAnimatedSprite.Move(MoveCount: Double);
begin
   if AnimSpeed > 0 then
  begin
    AnimPos := AnimPos + AnimSpeed * MoveCount;
    FPatternIndex := Round(AnimPos);

    if (Round(AnimPos) > AnimStart + AnimCount) then
    begin
      if (Round(AnimPos)) = AnimStart + AnimCount then
        if AnimLooped then
        begin
          AnimPos := AnimStart;
          FPatternIndex := Round(AnimPos);
        end
        else
        begin
          AnimPos := AnimStart + AnimCount - 1;
          FPatternIndex := Round(AnimPos);
        end;
    end;

    if FDoAnimated = True then
    begin
      if Round(AnimPos) >= AnimCount + 1 then
      begin
        FDoAnimated := False;
        AnimLooped := False;
        AnimSpeed := 0;
        AnimCount := 0;
        AnimPos := AnimStart;
        FPatternIndex := Round(AnimPos);
      end;
    end;

    if Round(AnimPos) < AnimStart then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Round(AnimPos);
    end;

    if Round(AnimPos) > AnimCount then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Trunc(AnimPos);
    end;
  end;
end;

procedure TRayAnimatedSprite.DoAnim(Looped: Boolean; Start: Integer;
  Count: Integer; Speed: Single);
begin
  FDoAnimated := True;
  AnimLooped := Looped;
  AnimStart := Start;
  AnimCount := Count;
  AnimSpeed := Speed;
end;

constructor TRayAnimatedSprite.Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture);
begin
  inherited Create(Engine, Texture);
  FAnimated := True;
  FlipState:= fsNormal;
end;

destructor TRayAnimatedSprite.Destroy;
begin
  inherited Destroy;
end;

{ TRaySprite }
procedure TRaySprite.SetTextureName(Value: string);
var i: Integer;
begin
  FTextureName := Value;
  for i := 0 to Length(FTexture.TextureName) - 1 do
  begin
    if lowercase(FTextureName) = lowercase(FTexture.TextureName[i]) then
    begin
      TextureIndex := i;
      Pattern.Right := FTexture.Pattern[i].Height;
      Pattern.Bottom := FTexture.Pattern[i].Width;
      Exit;
    end;
  end;
  TextureIndex := -1;
end;

procedure TRaySprite.SetTextureIndex(Value: Integer);
begin
 FTextureIndex := Value;
 if high(FTexture.Pattern) >=0 then
 begin
 Pattern.Right := FTexture.Pattern[FTextureIndex].Height;
 Pattern.Bottom := FTexture.Pattern[FTextureIndex].Width;
 end else
    TraceLog(LOG_ERROR,PChar(ModuleName+'The texture index('+
    inttostr(Value)+') does not exist'));
end;

procedure TRaySprite.DoCollision(const Sprite: TRaySprite);
begin

end;

procedure TRaySprite.Draw();
var Source: TRectangle;
    Dest: TRectangle;
    WH:TVector2;
    AlphaColor:TColor;
    i: integer;
begin
   if TextureIndex  <> -1 then
   begin
     if Assigned(FEngine) then
     begin
        if Visible then
        begin
          if FShowCollide then

          case FCollideMethod of
             cmRectangle: DrawRectangleRec(Self.CollideRect,RED);
             cmCircle: DrawCircleV(Self.CollidePos ,Self.CollideRadius,RED);
             cmPolygon:
                    for i:=0 to Length(FCollidePolygon) -1 do
                    DrawPixelV(FCollidePolygon[i],RED);
            end;

             case FlipState of
            fsNormal :
              RectangleSet(@Source,0,0,FTexture.Pattern[FTextureIndex].Width,FTexture.Pattern[FTextureIndex].Height);
            fsX:
              RectangleSet(@Source,0,0,-FTexture.Pattern[FTextureIndex].Width,FTexture.Pattern[FTextureIndex].Height);
            fsY:
              RectangleSet(@Source,0,0,FTexture.Pattern[FTextureIndex].Width,-FTexture.Pattern[FTextureIndex].Height);
            fsXY:
              RectangleSet(@Source,0,0,-FTexture.Pattern[FTextureIndex].Width,-FTexture.Pattern[FTextureIndex].Height);
           end;

           RectangleSet(@Dest,X,Y,
           FTexture.Pattern[FTextureIndex].Width*Scale,
           FTexture.Pattern[FTextureIndex].Height*Scale);

           WH:=Vector2Create(0,0);
           AlphaColor:=White;  AlphaColor.a:=alpha;

           DrawTexturePro(FTexture.Texture[FTextureIndex],Source,Dest,WH,Angle,AlphaColor);
         end;
        end;
     end;
  end;


procedure TRaySprite.Move(MoveCount: Double);
begin

end;

procedure TRaySprite.Dead();
begin
   if IsSpriteDead = False then
  begin
    IsSpriteDead := True;
    FEngine.FDeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure TRaySprite.SetOrder(Value: Single);
begin
  if FZ <> Value then FZ := Value;
  FEngine.SetZOrder;
end;

procedure TRaySprite.SetScale(Value: Single);
begin
  FScale := Value;
end;

procedure TRaySprite.Collision(const Other: TRaySprite);
var IsCollide: Boolean;
begin
  IsCollide:=False;
  if (FCollisioned) and (Other.FCollisioned) and (not IsSpriteDead)and (not Other.IsSpriteDead) then
  begin
    case FCollideMethod of
      cmRectangle: IsCollide := CheckCollisionRecs(Self.CollideRect,Other.CollideRect);
      cmCircle: IsCollide:=CheckCollisionCircles(Self.CollidePos,Self.CollideRadius,Other.CollidePos,Other.CollideRadius);
      cmPointRec: IsCollide:=CheckCollisionPointRec(Self.CollidePos,Other.CollideRect);
      cmPointCircle: IsCollide:=CheckCollisionPointCircle(Self.CollidePos,Other.CollidePos,Other.CollideRadius);
      cmPolygon: IsCollide:=OverlapPolygon(Self.CollidePolygon,Other.CollidePolygon);
    end;
    if IsCollide then
     begin
      DoCollision(Other);
      Other.DoCollision(Self);
     end;
  end;
end;

procedure TRaySprite.Collision;
  var
   i: Integer;
begin
     if (FEngine<>nil) and (not IsSpriteDead) and (Collisioned) then
     begin
          for i:=0 to FEngine.FList.Count-1 do
              Self.Collision(TRaySprite(FEngine.FList.Items[i]));
     end;

end;

constructor TRaySprite.Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture);
begin
  if (Assigned(Engine)) and (Assigned(Texture)) then
  begin
  FAnimated := False;
  FEngine := Engine;
  FEngine.FList.Add(Self);
  FTexture := Texture;
  Pattern.Left := 0;
  Pattern.Top := 0;
  Alpha := 255;
  Scale  := 1.0;
  Visible := True;
  TraceLog(LOG_INFO, ModuleName+'Sprite engine created successfully');
  end else
   begin
     TraceLog(LOG_ERROR, ModuleName+'No SpriteEngine or Game Texture was created.');
   end;
end;

destructor TRaySprite.Destroy;
begin
  inherited Destroy;
end;

{ TRayGameTexture }
function TRayGameTexture.LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
begin
   if not fileexists(PChar(FileName)) then
  begin
    Result := False;
    TraceLog(LOG_ERROR,PChar( ModuleName+'File '+FileName+' no exits.'));
    Exit;
  end;
  SetLength(Texture, Count + 1);
  SetLength(TextureName, Count + 1);
  SetLength(Pattern, Count + 1);
  Inc(Count);
  TextureName[Count - 1] := FileName;
  Pattern[Count - 1].Height := Height;
  Pattern[Count - 1].Width := Width;
  Texture[Count - 1] := LoadTexture(PChar(FileName));
  Result := True;
end;

constructor TRayGameTexture.Create;
begin
  TraceLog(LOG_INFO, ModuleName+'Game texture created successfully');
end;

destructor TRayGameTexture.Destroy;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    TextureName[i] := '';
    Pattern[i].Height := 0;
    Pattern[i].Width := 0;
    UnloadTexture(Texture[i]);
    TraceLog(LOG_INFO, ModuleName+'Unload texture');
  end;
  SetLength(TextureName, 0);
  SetLength(Texture, 0);
  SetLength(Pattern, 0);
  Count := 0;
  TraceLog(LOG_INFO, ModuleName+'Game texture destroy');
  inherited Destroy;
end;

procedure TRaySpriteEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure TRaySpriteEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure TRaySpriteEngine.Draw();
var  i: Integer;
begin
 for i := 0 to FList.Count - 1 do
   begin
    if TRaySprite(FList.Items[i]).FAnimated = False then TRaySprite(FList.Items[i]).Draw
    else TRayAnimatedSprite(FList.Items[i]).Draw;
   end;
end;

procedure TRaySpriteEngine.ClearDeadSprites;
var i: Integer;
begin
  for i := 0 to FDeadList.Count - 1 do
  begin
    if FDeadList.Count >= 1 then
    begin
      if TRaySprite(FDeadList.Items[i]).IsSpriteDead = True then
      begin
        TRaySprite(FDeadList.Items[i]).FEngine.FList.Remove(FDeadList.Items[i]);
      end;
    end;
  end;
  FDeadList.Clear;
end;

procedure TRaySpriteEngine.Move(MoveCount: Double);
var i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if TRaySprite(FList.Items[i]).FAnimated = False then
       TRaySprite(FList.Items[i]).Move(MoveCount)
    else
      TRayAnimatedSprite(FList.Items[i]).Move(MoveCount);
  end;
end;


procedure TRaySpriteEngine.SetZOrder();
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
      if TRaySprite(FList.Items[i]).Z < TRaySprite(FList.Items[i - 1]).Z then
      begin
        FList.Move(i, i - 1);
        break;
      end;
    end;
  until Done;
end;

constructor TRaySpriteEngine.Create;
begin
  FList := TList.Create;
  FDeadList := TList.Create;
end;

destructor TRaySpriteEngine.Destroy;
var i: Integer;
begin
  for i := 0 to FList.Count - 1 do  TRaySprite(FList.Items[i]).Destroy;
  FList.Destroy;
  FDeadList.Destroy;
  inherited Destroy;
end;

end.


