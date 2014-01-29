ui_print("");
ui_print("");
ui_print("------------------------------------------------");
ui_print("@VERSION");
ui_print("  KBC Developers:");
ui_print("  HomuHomu ma34s sakulamilk:");
ui_print("    built by @BUILDER");
ui_print("------------------------------------------------");
ui_print("");
show_progress(0.500000, 0);

ui_print("flashing recovery image...");
package_extract_file("unlocked_bootloaders", "/tmp/unlocked_bootloaders");
package_extract_file("loki_bootloaders", "/tmp/loki_bootloaders");
package_extract_file("loki_patch", "/tmp/loki_patch");
package_extract_file("loki_flash", "/tmp/loki_flash");
package_extract_file("loki.sh", "/tmp/loki.sh");
set_perm(0, 0, 0777, "/tmp/loki_patch");
set_perm(0, 0, 0777, "/tmp/loki_flash");
set_perm(0, 0, 0777, "/tmp/loki.sh");
package_extract_file("recovery.img", "/tmp/recovery.img");
show_progress(0.700000, 0);
assert(run_program("/tmp/loki.sh") == 0);
show_progress(0.900000, 0);
delete("/tmp/loki.sh");
delete("/tmp/loki_bootloaders");
delete("/tmp/unlocked_bootloaders");
delete("/tmp/loki_patch");
delete("/tmp/loki_flash");
delete("/tmp/loki.sh");

ui_print("flash complete. Enjoy!");
set_progress(1.000000);

