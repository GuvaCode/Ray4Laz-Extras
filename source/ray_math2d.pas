unit ray_math2d;

interface

uses
 ray_header, Types, Math;

//---------------------------------------------------------------------------
type
 PRayPolygon = ^TRayPolygon;
 TRayPolygon = array of TVector2;
//--------------------------------------------------------------------------

 // returns True if polygons overlap
// last points of polygons must be the first one ( P1[0] = P1[N]  ; P2[0] = P2[N] )
//---------------------------------------------------------------------------
function OverlapPolygon(const P1, P2: TRayPolygon): Boolean;
function RotatePolygon(const RotAng:Single; const Polygon:TRayPolygon):TRayPolygon; overload;
procedure Rotate(const RotAng:Single; const x,y,ox,oy:Single; out Nx,Ny:Single); overload;
function Rotate(const RotAng:Single; const Point,OPoint:TVector2):TVector2; overload;
function Rotate(const RotAng:Single; const Polygon  : TRayPolygon; const OPoint:TVector2):TRayPolygon; overload;
function PtInPolygon(const Pt: TVector2; const Pg: TRayPolygon):Boolean;
function Cos256(i: Integer): Real;
function Sin256(i: Integer): Real;
procedure Rotate(RotAng:Single; const x,y:Single; out Nx,Ny:Single); overload;
function Rotate(const RotAng:Single; const Point:TVector2):TVector2;  overload;
function NotEqual(const Val1,Val2,Epsilon:Single):Boolean;  overload;
function NotEqual(const Val1,Val2:Single):Boolean;    overload;
procedure Centroid(const Polygon:TRayPolygon; out x,y:Single);overload;
function Translate(const Dx,Dy:Single;   const Polygon   : TRayPolygon):TRayPolygon;     overload;
function CenterAtLocation(const Polygon: TRayPolygon; const x,y:Single ):TRayPolygon; overload;

const Epsilon_Medium    = 1.0E-12;
const PIDiv180  =  0.017453292519943295769236907684886;
const Zero              = 0.0;
  const Epsilon           = Epsilon_Medium;
implementation

procedure Rotate(RotAng:Single; const x,y:Single; out Nx,Ny:Single);
var
  SinVal : Single;
  CosVal : Single;
begin
  RotAng := RotAng * PIDiv180;
  SinVal := Sin(RotAng);
  CosVal := Cos(RotAng);
  Nx     := (x * CosVal) - (y * SinVal);
  Ny     := (y * CosVal) + (x * SinVal);
end;

function Rotate(const RotAng:Single; const Point:TVector2):TVector2;
begin
  Rotate(RotAng,Point.x,Point.y,Result.x,Result.y);
end;

function NotEqual(const Val1, Val2: Single): Boolean;
begin
  Result := NotEqual(Val1,Val2,Epsilon);
end;

function NotEqual(const Val1, Val2, Epsilon: Single): Boolean;
var
  Diff : Single;
begin
  Diff := Val1 - Val2;
  Assert(((-Epsilon > Diff) or (Diff > Epsilon)) = (Abs(Val1 - Val2) > Epsilon),'Error - Illogical error in equality check. (NotEqual)');
  Result := ((-Epsilon > Diff) or (Diff > Epsilon));

end;



procedure Centroid(const Polygon: TRayPolygon; out x, y: Single);
var
  i    : Integer;
  j    : Integer;
  asum : Single;
  term : Single;
begin
  x := Zero;
  y := Zero;

  if Length(Polygon) < 3 then Exit;

  asum := Zero;
  j    := Length(Polygon) - 1;

  for i := 0 to Length(Polygon) - 1 do
  begin
    term := ((Polygon[j].x * Polygon[i].y) - (Polygon[j].y * Polygon[i].x));
    asum := asum + term;
    x := x + (Polygon[j].x + Polygon[i].x) * term;
    y := y + (Polygon[j].y + Polygon[i].y) * term;
    j := i;
  end;

  if NotEqual(asum,Zero) then
  begin
    x := x / (3.0 * asum);
    y := y / (3.0 * asum);
  end;
end;

function Translate(const Dx, Dy: Single; const Polygon: TRayPolygon): TRayPolygon;
var
  i : Integer;
begin
  SetLength(Result,Length(Polygon));
  for i := 0 to Length(Polygon) - 1 do
  begin
    Result[i].x := Polygon[i].x + Dx;
    Result[i].y := Polygon[i].y + Dy;
  end;

end;

function CenterAtLocation(const Polygon: TRayPolygon; const x, y: Single): TRayPolygon;
  var
  Cx : Single;
  Cy : Single;
begin
  Centroid(Polygon,Cx,Cy);
  Result := Translate(x - Cx,y - Cy,Polygon);
end;

function RotatePolygon(const RotAng:Single; const Polygon:TRayPolygon):TRayPolygon;
var
  i : Integer;
begin
  SetLength(Result,Length(Polygon));
  for i := 0 to Length(Polygon) - 1 do
  begin
    Result[i] := Rotate(RotAng,Polygon[i]);
  end;
end;

procedure Rotate(const RotAng: Single; const x, y, ox, oy: Single; out Nx,
  Ny: Single);
begin
   Rotate(RotAng,x - ox,y - oy,Nx,Ny);
  Nx := Nx + ox;
  Ny := Ny + oy;
end;

function Rotate(const RotAng: Single; const Point, OPoint: TVector2): TVector2;
begin
    Rotate(RotAng,Point.x,Point.y,OPoint.x,OPoint.y,Result.x,Result.y);
end;

function Rotate(const RotAng: Single; const Polygon: TRayPolygon;
  const OPoint: TVector2): TRayPolygon;
var
  i : Integer;
begin
  SetLength(Result,Length(Polygon));
  for i := 0 to Length(Polygon) - 1 do
  begin
    Result[i] := Rotate(RotAng,Polygon[i],OPoint);
  end;

end;

{ algorithm by Paul Bourke }
function PtInPolygon(const Pt: TVector2; const Pg: TRayPolygon): Boolean;
var
  N, Counter , I : Integer;
  XInters : Real;
  P1, P2 : TVector2;
begin
  N := High(Pg);
  Counter := 0;
  P1 := Pg[0];
  for I := 1 to N do
  begin
    P2 := Pg[I mod N];
    if Pt.y > Min(P1.y, P2.y) then
      if Pt.y <= Max(P1.y, P2.y) then
        if Pt.x <= Max(P1.x, P2.x) then
          if P1.y <> P2.y then
          begin
            XInters := (Pt.y - P1.y) * (P2.x - P1.x) / (P2.y - P1.y) + P1.x;
            if (P1.x = P2.x) or (Pt.x <= XInters) then Inc(Counter);
          end;
    P1 := P2;
  end;
  Result := (Counter mod 2 <> 0);
end;

//---------------------------------------------------------------------------
{ NOTE: last points of polygons must be the first one ( P1[0] = P1[N]  ; P2[0] = P2[N] ) }
function OverlapPolygon(const P1, P2: TRayPolygon): Boolean;
var
  Poly1, Poly2 : TRayPolygon;
  I, J : Integer;
  xx , yy : Single;
  StartP, EndP : Integer;
  Found : Boolean;
begin
  Found := False;
  { Find polygon with fewer points }
  if High(P1) < High(P2) then
  begin
    Poly1 := P1;
    Poly2 := P2;
  end
  else
  begin
    Poly1 := P2;
    Poly2 := P1;
  end;

  for I := 0 to High(Poly1) - 1 do
  begin
    { Trace new line }
    StartP := Round(Min(Poly1[I].x, Poly1[I+1].x));
    EndP   := Round(Max(Poly1[I].x, Poly1[I+1].x));


    if StartP = EndP then
    { A vertical line (ramp = inf) }
    begin
      xx := StartP;
      StartP := Round(Min(Poly1[I].y, Poly1[I+1].y));
      EndP   := Round(Max(Poly1[I].y, Poly1[I+1].y));
      { Follow a vertical line }
      for J := StartP to EndP do
      begin
        { line equation }
        if PtInPolygon(Vector2Create(xx,j),Poly2)
         then
        begin
          Found := True;
          Break;
        end;
      end;
    end
    else
    { Follow a usual line (ramp <> inf) }
    begin
      { A Line which X is its variable i.e. Y = f(X) }
      if Abs(Poly1[I].x -  Poly1[I+1].x) >= Abs(Poly1[I].y -  Poly1[I+1].y) then
      begin
        StartP := Round(Min(Poly1[I].x, Poly1[I+1].x));
        EndP   := Round(Max(Poly1[I].x, Poly1[I+1].x));
        for J := StartP to EndP do
        begin
          xx := J;
          { line equation }
          yy := (Poly1[I+1].y - Poly1[I].y) / (Poly1[I+1].x - Poly1[I].x) * (xx - Poly1[I].x) + Poly1[I].y;
          if PtInPolygon(Vector2Create(xx,yy), Poly2) then
          begin
            Found := True;
            Break;
          end;
        end;
      end
      { A Line which Y is its variable i.e. X = f(Y) }
      else
      begin
        StartP := Round(Min(Poly1[I].y, Poly1[I+1].y));
        EndP   := Round(Max(Poly1[I].y, Poly1[I+1].y));
        for J := StartP to EndP do
        begin
          yy := J;
          { line equation }
          xx := (Poly1[I+1].x - Poly1[I].x) / (Poly1[I+1].y - Poly1[I].y) * (yy - Poly1[I].y) + Poly1[I].x;
          if PtInPolygon(Vector2Create(xx,yy), Poly2) then
          begin
            Found := True;
            Break;
          end;
        end;
      end;
    end;
    if Found then Break;
  end;

  { Maybe one polygon is completely inside another }
  if not Found then
    Found := PtInPolygon(Poly1[0], Poly2) or PtInPolygon(Poly2[0], Poly1);

  Result := Found;
end;


//---------------------------------------------------------------------------
//precalculated fixed  point  cosines for a full circle
var
  CosTable256: array[0..255] of Double;


procedure InitCosTable;
var
  i: Integer;
begin
   for i:=0 to 255 do
    CosTable256[i] := Cos((i/256)*2*PI);
end;

function Cos256(i: Integer): Real;
begin
  Result := CosTable256[i and 255];
end;

function Sin256(i: Integer): Real;
begin
  Result := CosTable256[(i+192) and 255];
end;


 initialization
 InitCosTable();

end.

