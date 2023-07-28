import { Denops } from "https://deno.land/x/denops_core@v5.0.0/denops.ts";
import { is } from "https://deno.land/x/unknownutil@v3.4.0/mod.ts";
import { parse } from "https://deno.land/std@0.196.0/yaml/parse.ts";

export function main(denops: Denops) {
  denops.dispatcher = {
    parseYaml: async (path: unknown) => {
      if (!is.String(path)) {
        return;
      }

      const content = await Deno.readTextFile(path);
      return parse(content);
    },
  };
}
