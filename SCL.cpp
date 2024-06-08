#include<iostream>
#include<algorithm>
#include<vector>
#include<fstream>
#include<cstdlib>
#include<time.h>
using namespace std;

#define Sd 0
#define Sa 1
#define Sb 2
#define Se 3

vector<int> SCL_direct_selection(vector< vector<int> > D){ // Algorithm itself
	int L = D.size() / 2, M = D[0].size();
	int state = Sd, r_f = L, n0 = 0, s = 0;
	vector<int> E(2*L, 0), F(2*L, 0);
	bool lastbit = 0;

	while(true){
		if(state == Sd){
			n0 = 0;
			for(int i=0; i<2*L; i++)
				n0 = n0 + (!D[i][s] & !E[i]);
			if (n0 < r_f)	state = Sa;
			else if(n0 > r_f) state = Sb;
			else state = Se;
		}
		else if(state == Sa){
			r_f = r_f - n0;
			for(int i=0; i<2*L; i++){
				F[i] = (!D[i][s] & !E[i]) | F[i];
				E[i] = !D[i][s] | E[i];
			}
			s++;
			if(s != M) state = Sd;
			else state = Se, lastbit = 1;
		}
		else if(state == Sb){
			for(int i=0; i<2*L; i++)
				E[i] = D[i][s] | E[i];
			s++;
			if(s != M) state = Sd;
			else state = Se, lastbit = 1;
		}
		else{
			if (lastbit == 0){
				for(int i=0; i<2*L; i++){
					F[i] = (!D[i][s] & !E[i]) | F[i];
					E[i] = 1;
				}
				r_f = 0;
			}
			else{
				for(int i=0; i<2*L && r_f>0; i++){
					if(E[i] == 0)
						F[i] = 1, r_f--;
					E[i] = 1;
				}
			}
			break;
		}
	}
	
	return F;
}

void gentest(int L, int M, int N){ // generate N test cases, each testcase has 2*L numbers, every number is M-bit
	srand(time(0));
	unsigned long long bound = (unsigned long long) 1<<M, num1;
	ofstream outfile;
	outfile.open("./testcases/inputs/L"+to_string(L)+"_M"+to_string(M)+".txt");
	for(int n=0;n<N;n++){
		for(int i=0;i<2*L;i++){
			num1 = rand();
			outfile << num1 % bound << " ";
		}
		outfile<<endl;
	}
	outfile.close();
}

vector<int> int_to_bits(unsigned long long a, int M){ // convert integer to binary
	vector<int>v;
	for(int i=0;i<M;i++, a/=2) v.insert(v.begin(), a%2);
	return v;
}

int checkres(vector<unsigned long long> in, vector<unsigned long long>out){ // check if the input and output are matching by sorting and comparing both
	int n = out.size(), check = 1;
	sort(in.begin(),in.end());
	sort(out.begin(),out.end());
	
	for(int i=0; i<n; i++)
		if(in[i] != out[i]) check = 0;
	return check;
}

main(){
	int n, L, M, succ, success = 1;
	cin>>L>>M>>n; // input L M and n here
	gentest(L, M, n);

	vector< vector<int> >v(2*L, vector<int>(M));
	vector<unsigned long long> inputs(2*L), outputs;
	vector<int> res(2*L);

	ifstream infile;
	ofstream outfile;
	infile.open("./testcases/inputs/L"+to_string(L)+"_M"+to_string(M)+".txt");
	outfile.open("./testcases/outputs/L"+to_string(L)+"_M"+to_string(M)+"_out.txt"); // in and out files generated automatically with the name "LxxMxx"

	while(1){
		outputs.clear();
		for(int i=0;i<2*L;i++){
			infile >> inputs[i]; // read inputs from the file
			v[i] = int_to_bits(inputs[i],M);
		}
		if(infile.eof()) break;
		res = SCL_direct_selection(v);

		for(int i=0; i<2*L; i++){
			if(res[i]) outputs.push_back(inputs[i]);
			outfile << res[i]; // write the output to the file
		}
		outfile<<endl;
		succ = checkres(inputs, outputs); // check if the output is correct
		
		if(succ){
			//cout<<"test passed\n\n";
		}
		else{
			cout<<"test failed\n\n"; 
			success = 0;
		}
		
	}

	if(success) cout<<"\nall tests passed\n"; else cout<<"\nsome tests failed\n";	
	infile.close();
	outfile.close();
	cout.precision(11);
	return 0;
}
