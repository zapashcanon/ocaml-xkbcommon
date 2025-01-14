open Base
open Stdio
module C = Configurator

let write_sexp fn sexp =
  Out_channel.write_all fn ~data:(Sexp.to_string sexp)

type config = {
  name : string;
  default_libs : string list;
  default_cflags : string list;
  package : string;
}

let discover { name; default_libs; default_cflags; package } =
  C.main ~name (fun c ->
    let default : C.Pkg_config.package_conf =
      { libs   = default_libs
      ; cflags = default_cflags
      }
    in
    let conf =
      match C.Pkg_config.get c with
      | None -> default
      | Some pc ->
        Option.value (C.Pkg_config.query pc ~package) ~default
    in

    write_sexp (name ^ "-cclib.sexp") (sexp_of_list sexp_of_string conf.libs);
    write_sexp (name ^ "-ccopt.sexp") (sexp_of_list sexp_of_string conf.cflags);
    Out_channel.write_all (name ^ "-cclib") ~data:(String.concat conf.libs   ~sep:" ");
    Out_channel.write_all (name ^ "-ccopt") ~data:(String.concat conf.cflags ~sep:" ")
  )

let () =
  [ { name = "xkbcommon";
      default_libs = ["-lxkbcommon"];
      default_cflags = [];
      package = "xkbcommon" };
  ] |> List.iter ~f:discover
