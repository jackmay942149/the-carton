package carton

import fmt  "core:fmt"
import glfw "vendor:glfw"
import str  "core:strings"
import vk   "vendor:vulkan"

Vulkan_Ctx :: struct {
	instance: vk.Instance
}

g_vk_ctx: Vulkan_Ctx

@(private)
vulkan_init :: proc(project_name: string) {
	vk.load_proc_addresses_global(rawptr(glfw.GetInstanceProcAddress))
	project_name_n := str.clone_to_cstring(project_name, context.allocator)
	app_info := vk.ApplicationInfo {
		pApplicationName = project_name_n,
		applicationVersion = vk.MAKE_VERSION(1, 0, 0),
		pEngineName = "No Engine",
		engineVersion = vk.MAKE_VERSION(1, 0, 0),
		apiVersion = vk.API_VERSION_1_4,
	}
	fmt.println(app_info)

	extensions := glfw.GetRequiredInstanceExtensions()
	instance_info := vk.InstanceCreateInfo {
		pApplicationInfo = &app_info,
		ppEnabledExtensionNames = raw_data(extensions),
		enabledExtensionCount = u32(len(extensions)),
	}
	res := vk.CreateInstance(&instance_info, nil, &g_vk_ctx.instance)
	vk_assert(res, "Failed to create instance")
	fmt.println("Created instance", g_vk_ctx.instance)
	vk.load_proc_addresses_instance(g_vk_ctx.instance)
}

@(private="file")
vk_assert :: proc(res: vk.Result, message: string) {
	if res != .SUCCESS {
		fmt.println(res)
		panic(message)
	}
}

