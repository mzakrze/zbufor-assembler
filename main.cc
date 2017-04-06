#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern "C" int InitBuffers(unsigned char *image,unsigned char *zbuf,int xsize,int ysize,unsigned char *rgb);

#define WORD short
#define DWORD unsigned
#define LONG int
#define BYTE char


typedef struct
{
    WORD bfType;
    DWORD bfSize;
    WORD bfReserved1;
    WORD bfReserved2;
    DWORD bfOffBits;
}BITMAPFILEHEADER;

typedef struct
{
    DWORD biSize;
    LONG  biWidth;
    LONG  biHeight;
    WORD  biPlanes;
    WORD biBitCount;
    DWORD biCompression;
    DWORD biSizeImage;
    LONG  biXPelsPerMeter;
    LONG biYPelsPerMeter;
    DWORD biClrUsed;
    DWORD biClrImportant;
}BITMAPINFOHEADER;

void swap_int(unsigned int *buf1,unsigned int *buf2)
{
  unsigned int temp[3];
  temp[0] = *buf1;
  temp[1] = *(buf1+1);
  temp[2] = *(buf1+2);
  *buf1 = *buf2;
  *(buf1+1) = *(buf2+1);
  *(buf1+2) = *(buf2+2);
  *buf2 = temp[0];
  *(buf2+1) = temp[1];
  *(buf2+2) = temp[2];
}

extern "C" int DrawTriangle(unsigned char *image,unsigned char*zbuf,unsigned int xsize,unsigned int ysize,unsigned int *verticles,unsigned char *rgb);

void swap_char(unsigned char *a,unsigned char *b)
{
  unsigned char tab[3];
  tab[0] = *a;
  tab[1] = *(a+1);
  tab[2] = *(a+2);
  *a = *b;
  *(a+1) = *(b+1);
  *(a+2) = *(b+2);
  *b = tab[0];
  *(b+1) = tab[1];
  *(b+2) = tab[2];
}

void sort_by_y(unsigned int *verticles,unsigned char *rgb) // sorts so that (1) is the lowest and (3) highest
{
  if(*(verticles+1) > *(verticles+4) )  // swap (1) & (2)
  {
    swap_int( verticles,verticles+3);
    swap_char( rgb,rgb+3);
  }
  if(*(verticles+1) > *(verticles+7))  // swap (1) & (3)
  {
    swap_int( verticles,verticles+6);
    swap_char( rgb,rgb+6);
  }
  if(*(verticles+4) > *(verticles+7))  // swap (2) & (3)
  {
    swap_int( verticles+3,verticles+6);
    swap_char( rgb+3,rgb+6);
  }

}

int main(int argc,char **argv)
{
  if(argc == 1 || argc >=3)
  {
    printf("input file name not given or given to many, returning\n");
    return 0;
  }
  unsigned int xsize,ysize;
  unsigned char *image, *zbuf;
  unsigned int verticles[9];
  unsigned char rgb[9];
  int result;
  FILE *opis;
  unsigned int temp;

  opis = fopen(argv[1],"r");
  if(opis == NULL)
  {
    printf("file open failed\n");
    return 0;
  }
  printf("file opened successfully\n");

  fscanf(opis,"%d",&xsize);
  fscanf(opis,"%d",&ysize);

  image = (unsigned char*) malloc (sizeof(unsigned char) * xsize * ysize * 3);
  zbuf = (unsigned char*) malloc (sizeof(unsigned char) * xsize * ysize * 3);

  fscanf(opis,"%d",&rgb[0]);
  fscanf(opis,"%d",&rgb[1]);
  fscanf(opis,"%d",&rgb[2]);
	
  result = InitBuffers(image,zbuf,xsize,ysize,rgb);
  if(result != 0)
  {
    printf("error while initiating buffers, error number: %d\n",result);
    return 0;
  }
  /* reading triangles from file  and processing them in DrawTriangle()*/
  while(true)
  {
    /////////////////   reading (1) vertex  ////////////////
    fscanf(opis,"%d",verticles);
    if(feof(opis))  /* feof() return true after beeing unable to read from file */
       break;
    if(*verticles >= xsize)
    {
      printf("error: coordinate x is out of range\n");
      return 0;
    }
    fscanf(opis,"%d",&verticles[1]);
    if(*(verticles+1) >= ysize)
    {
      printf("error: coordinate y is out of range(1 vertex):ysize=%d,v=%d\n",ysize,*(verticles+1));
      return 0;
    }
    *(verticles+1) = ysize - *(verticles+1) - 1; // reverse the y coordinate
    fscanf(opis,"%d",&verticles[2]);
	verticles[2] = verticles[2] / 2; /////////////////////////////////////////temp
    if(*(verticles+2) >= 0xFFFFFFFF)
    {
	printf("error: coordinate z is out of range");
	return 0;
    }
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[0] = (unsigned char)temp;
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[1] = (char)temp;
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[2] = (char)temp;

    /////////////////   reading (2) vertex  ////////////////
    fscanf(opis,"%d",verticles+3);
    if(*(verticles+3) >= xsize)
    {
      printf("error: coordinate x is out of range");
      return 0;
    }
    fscanf(opis,"%d",verticles+4);
    if(*(verticles+4) >= ysize)
    {
      printf("error: coordinate y is out of range(2 vertex");
      return 0;
    }
    *(verticles+4) = ysize - *(verticles+4) - 1; // reverse the y coordinate
    fscanf(opis,"%d",verticles+5);
	verticles[5] = verticles[5] / 2; //////////////////////////////////////////////temp
    if(*(verticles+5) >= 0xFFFFFFFF)
    {
	printf("error: coordinate z is out of range");
	return 0;
    }
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[3] = (char)temp;
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[4] = (char)temp;
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[5] = (char)temp;

    /////////////////   reading (3) vertex  ////////////////
    fscanf(opis,"%d",verticles+6);
    if(*(verticles+6) >= xsize)
    {
      printf("error: coordinate x is out of range");
      return 0;
    }
    fscanf(opis,"%d",verticles+7);
    if(*(verticles+7) >= ysize)
    {
      printf("error: coordinate y is out of range(3 vertex)");
      return 0;
    }
    *(verticles+7) = ysize - *(verticles+7) - 1; // reverse the y coordinate
    fscanf(opis,"%d",verticles+8);
	verticles[8] = verticles[8] / 2; /////////////////////////////////////////////////////temp
    if(*(verticles+8) >= 0xFFFFFFFF)
    {
	printf("error: coordinate z is out of range");
	return 0;
    }
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[6] = (char)temp;
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[7] = (char)temp;
    fscanf(opis,"%d",&temp);
    if(temp > 255 || temp < 0)
    {
	printf("error: rgb component is out of range");
	return 0;
    }
    rgb[8] = (char)temp;

    /* done reading 3 verticles */
    sort_by_y(verticles,rgb);
    result = DrawTriangle(image,zbuf,xsize,ysize,verticles,rgb);
    if(result != 0)
    {
      printf("error while drawing triangle, error number: %d",result);
      return 0;
    }
  } /* done reading triangles from file and processing them*/

    BITMAPINFOHEADER infoHeader;
    BITMAPFILEHEADER fileHeader;

    fileHeader.bfType = 19778;
    fileHeader.bfSize = xsize*ysize*4 + 14+40;
    fileHeader.bfReserved1 = 0;
    fileHeader.bfReserved2 = 0;
    fileHeader.bfOffBits = 40 + 14;

    infoHeader.biSize = 40;
    infoHeader.biWidth = xsize;
    infoHeader.biHeight = ysize;
    infoHeader.biPlanes = 1;
    infoHeader.biBitCount = 24;
    infoHeader.biCompression = 0;
    infoHeader.biSizeImage = 0;
    infoHeader.biXPelsPerMeter = 0;
    infoHeader.biXPelsPerMeter = 0;
    infoHeader.biClrUsed = 0;
    infoHeader.biClrImportant = 0;

    FILE *zbuf_file,*scena_file;
    char zbuf_file_name[100];
    char scene_file_name[100];
    const char* zbuf_suffix = "_zbuf.bmp";
    const char* scene_suffix = "_scene.bmp";
    strncpy(zbuf_file_name, argv[1], sizeof(argv[1]));
    strncat(zbuf_file_name, zbuf_suffix, sizeof(zbuf_file_name) - strlen(zbuf_file_name) + 1);
    strncpy(scene_file_name, argv[1], sizeof(argv[1]));
    strncat(scene_file_name, scene_suffix, sizeof(scene_file_name) - strlen(scene_file_name) + 1);

    zbuf_file = fopen(zbuf_file_name,"wb");
    scena_file = fopen(scene_file_name,"wb");

    fwrite(&fileHeader.bfType,1,2,zbuf_file);
    fwrite(&fileHeader.bfSize,1,4,zbuf_file);
    fwrite(&fileHeader.bfReserved1,1,2,zbuf_file);
    fwrite(&fileHeader.bfReserved2,1,2,zbuf_file);
    fwrite(&fileHeader.bfOffBits,1,4,zbuf_file);

    fwrite(&infoHeader.biSize,1,4,zbuf_file);
    fwrite(&infoHeader.biWidth,1,4,zbuf_file);
    fwrite(&infoHeader.biHeight,1,4,zbuf_file);
    fwrite(&infoHeader.biPlanes,1,2,zbuf_file);
    fwrite(&infoHeader.biBitCount,1,2,zbuf_file);
    fwrite(&infoHeader.biCompression,1,4,zbuf_file);
    fwrite(&infoHeader.biSizeImage,1,4,zbuf_file);
    fwrite(&infoHeader.biXPelsPerMeter,1,4,zbuf_file);
    fwrite(&infoHeader.biYPelsPerMeter,1,4,zbuf_file);
    fwrite(&infoHeader.biClrUsed,1,4,zbuf_file);
    fwrite(&infoHeader.biClrImportant,1,4,zbuf_file);

    fwrite(&fileHeader.bfType,1,2,scena_file);
    fwrite(&fileHeader.bfSize,1,4,scena_file);
    fwrite(&fileHeader.bfReserved1,1,2,scena_file);
    fwrite(&fileHeader.bfReserved2,1,2,scena_file);
    fwrite(&fileHeader.bfOffBits,1,4,scena_file);

    fwrite(&infoHeader.biSize,1,4,scena_file);
    fwrite(&infoHeader.biWidth,1,4,scena_file);
    fwrite(&infoHeader.biHeight,1,4,scena_file);
    fwrite(&infoHeader.biPlanes,1,2,scena_file);
    fwrite(&infoHeader.biBitCount,1,2,scena_file);
    fwrite(&infoHeader.biCompression,1,4,scena_file);
    fwrite(&infoHeader.biSizeImage,1,4,scena_file);
    fwrite(&infoHeader.biXPelsPerMeter,1,4,scena_file);
    fwrite(&infoHeader.biYPelsPerMeter,1,4,scena_file);
    fwrite(&infoHeader.biClrUsed,1,4,scena_file);
    fwrite(&infoHeader.biClrImportant,1,4,scena_file);

    fwrite(zbuf,1,xsize*ysize*3,zbuf_file);
    fwrite(image,1,xsize*ysize*3,scena_file);

  fclose(opis);
  fclose(zbuf_file);
  fclose(scena_file);
  printf("Hello world!\n");
  return 0;
}
