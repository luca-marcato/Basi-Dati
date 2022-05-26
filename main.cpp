#include <cstdio>
#include <iostream>
#include <fstream>
#include "dependencies/include/libpq-fe.h"

#define PG_HOST		"127.0.0.1"
#define PG_USER		"postgres"
#define PG_DB		"ItaliExpress"
#define PG_PASS		"admin"
#define PG_PORT		5432

using namespace std;

void checkResultsNoData(PGresult* res, const PGconn* conn) {
	if(PQresultStatus(res) != PGRES_COMMAND_OK) {
		cout<<"Inconsistent Input:"<<endl<<PQerrorMessage(conn);
		PQclear(res);
		exit(1);
	}
}

int main(int argc, char **argv) {
	cout<<"Starting connection.."<<endl;
	
	
	char conninfo[250];
	
	sprintf(conninfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d",
			PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);
	
	PGconn *conn = PQconnectdb(conninfo);
	
	if(PQstatus(conn) != CONNECTION_OK) {
		cout<<"Errore di connessione"<<endl<<PQerrorMessage(conn);
		PQfinish(conn);
		exit(1);
	}
	
	cout<<"Database connected successfully"<<endl;
	
	string add_hubs_query = "INSERT INTO hubs (hub, country) VALUES ($1::varchar, $2::varchar)";
	
	PGresult *stmt = PQprepare(conn, "add_hubs", add_hubs_query.c_str(), 2, NULL);
	
	PGresult *res;
	for(int i = 0; i < 3; i++) {
		string name, code; 
		cout<<"Insert hub's name: ";
		cin>>name;
		cout<<"Insert code of the origin country: ";
		cin>>code;
		const char* params[] = {name.c_str(), code.c_str()};
		res = PQexecPrepared(conn, "add_hubs", 2, params, NULL, 0, 0);
		checkResultsNoData(res,conn);
	}
	
	return 0;
			
}