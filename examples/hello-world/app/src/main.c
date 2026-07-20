#include <stdlib.h>

#include <zephyr/kernel.h>
#include <zephyr/sys/sys_io.h>
#include <zephyr/sys/printk.h>

int main(void)
{
	printk("Hello from mise zephyr-sdk\n");

#if defined(CONFIG_ARCH_POSIX)
	exit(0);
#elif defined(CONFIG_X86)
	/* Zephyr's qemu_x86 runner adds isa-debug-exit at I/O port 0xf4. */
	sys_out8(0, 0xf4);
#else
	return 0;
#endif
}
