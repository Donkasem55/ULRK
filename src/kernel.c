typedef unsigned short uint16_t;
typedef unsigned char uint8_t;

char* PIN = "123456";

volatile uint16_t* vgabuf = (uint16_t*)0xB8000;
uint8_t attr = 0x010F;
char* osver = "ULRK-26.0";
char* krnlver = "0.0.1-ULRK-x86";
char* loginmsg = " Login\n";
char* loginwelc = "\n\n[PIN]: ";

void kernel_main(void) {
	
	while (1) {}
}

void clear() {
	asm (
		"cld\n",
		"mov $0xB8000, %edi\n",
		"mov $0x2000, %ecx\n",
		"rep stosw"
		: "a" (attr)
		: "memory"
	);
	return;
}

void print(char* string) {
	for (int i=0; string[i] != '\0'; i++) {
		vgabuf[i] = (uint8_t)str[i] | attr;
	}
	return;
}
