void sort(int *pNum, int size);
void swap(int *a, int *b);
void main(void) {
    int Num[6] = {3,5,9,1,7};
    int a = 0;
    sort(Num,5);

    a = 0x12345678;

    while (1);

    return;
}

void sort(int *pNum, int size){
    for(int i = 0; i < size ;  i++){
        for(int j = 0; j < size - i; j++){ //for(int j = 0; j < size - i; j++){
            if(pNum[j] > pNum[j + 1]){
                swap(&pNum[j],&pNum[j+1]);
            }
        }
    }
    return;
}

void swap (int *a, int *b){
    int temp = *a;
    *a = *b;
    *b = temp;
    return;
}