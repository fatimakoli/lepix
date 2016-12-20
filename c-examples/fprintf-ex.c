#include <stdio.h>
int main() {
	FILE *fp;
	int c;

	fp = fopen("file.txt", "w");
	fprintf(fp, "%s", "DEATH IS NIGH");
	fclose(fp);
}