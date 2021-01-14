{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit ray4laz_extra;

{$warn 5023 off : no warning about unused units}
interface

uses
<<<<<<< Updated upstream
  ray4lazEx_desc, ray_application, ray.sprites, LazarusPackageIntf;
=======
  ray4lazEx_desc, ray_application, ray_model, ray_sprites, LazarusPackageIntf;
>>>>>>> Stashed changes

implementation

procedure Register;
begin
  RegisterUnit('ray4lazEx_desc', @ray4lazEx_desc.Register);
end;

initialization
  RegisterPackage('ray4laz_extra', @Register);
end.
