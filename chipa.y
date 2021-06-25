%{
    #include "LinkedList.h"

    void yyerror(const char *s);
    
    int yylex();
%}

%union{
    char* texto;
    int numero;
}

%token FIN_LINEA; 
%token DOS_PUNTOS; 
%token MAS; 
%token MENOS;
%token POR;
%token DIVIDIDO; 
%token MOD; 
%token VERDADERO; 
%token FALSO; 
%token MENOR; 
%token MAYOR;
%token MENOR_IGUAL; 
%token MAYOR_IGUAL; 
%token IGUAL; 
%token PARENTESIS_ABRE; 
%token PARENTESIS_CIERRA; 
%token MIENTRAS;
%token HAZ; 
%token SI;
%token COMILLA; 
%token Y;
%token O;
%token NO; 
%token IMPRIMIR; 
%token SINO;
%token <numero> NUMERO;
%token <texto> TEXTO;
%token VAR_NUMERO; 
%token VAR_TEXTO; 
%token <texto> NOMBRE;
%token FIN;


%start S;

%%


S: begin CODE end;
begin: {printf("include \"LinkedList.h\"\n int main() {");};

end: {printf("}");};

CODE: | INSTRUCCION FIN_LINEA | CONTROL_LOGICO;

INSTRUCCION: 
    DECLARACION {}
    |asignacion {} 
    |declara_y_asigna {}
    |print {}

DECLARACION: VAR_NUMERO NOMBRE {
        if(find($2)!=NULL){
            yyerror("Variable ya definida");
            fprintf(stderr, "La variable ya se definio previamente");
            YYABORT;
        }
        else {
            insert($2, 0, 1);
        }
    }
    | VAR_TEXTO NOMBRE  {     
        if(find($2) != NULL){
            yyerror("Variable ya definida");
            fprintf(stderr, "La variable ya se definio previamente");
            YYABORT;
        }
        else {
            insert($2, '\0', 0);
        };
    }

asignacion: ASIGNACION_NUM | ASIGNACION_TEXT;

ASIGNACION_NUM:  NOMBRE '=' NUMERO{
    struct node* aux;
    if((aux=find($1)) != NULL){
        aux->data = (void *) &($3);
    }else{
        yyerror("La variable que se intento asignar no existe");
        fprintf(stderr, "La variable que se intento asignar no existe");
        YYABORT;
    }
};
    | NOMBRE '=' operacion;

ASIGNACION_TEXT:  NOMBRE '=' TEXTO{
    struct node* aux;
    if((aux=find($1)) != NULL){
        aux->data = (void *)$3;
    }else{
        yyerror("La variable que se intento asignar no existe");
        //fprintf(stderr, "Error en la linea %d. La variable que se intento asignar no existe", yylineno);
        fprintf(stderr, "Error en alguna linea, capo. La variable que se intento asignar no existe");
        YYABORT;
    }
};

declara_y_asigna: VAR_NUMERO NOMBRE '=' NUMERO{
    struct node* aux;
        if(find($2)!=NULL){
            yyerror("Variable ya definida");
            fprintf(stderr, "La variable ya se definio previamente");
            YYABORT;
        }
        else {
            insert($2, &($4), 1);
        }
    }
    |VAR_TEXTO NOMBRE '=' TEXTO{
        if(find($2)!=NULL){
            yyerror("Variable ya definida");
            fprintf(stderr, "La variable ya se definio previamente");
            YYABORT;
        }
        else {
            insert($2, $4, 0);
        }
    };


print: IMPRIMIR '(' TEXTO ')' { printf("printf(\" %s \")", $3); }; 
        | IMPRIMIR '(' NOMBRE ')'{
            struct node* aux;
            if((aux=find($3)) != NULL){
                if(aux->type == 1)
                    printf("printf(\" %d \")", aux->data);
                if(aux->type == 0)
                    printf("printf(\" %s \")", aux->data);
                    
            } else {
                yyerror("La variable que se intento imprimir no existe");
                //fprintf(stderr, "Error en la linea %d. La variable que se intento imprimir no existe", yylineno);
                fprintf(stderr, "Error en alguna linea, capo. La variable que se intento asignar no existe");
                YYABORT;
            }
        };


operacion: valor operador valor;

operador: MAS{printf(" + ");};
        |MENOS{printf(" - ");};
        |POR{printf(" * ");};
        |DIVIDIDO{printf(" / ");};
        |MOD{printf(" % ");};

parentesis_st_abre: PARENTESIS_ABRE{printf(" ( ");};
parentesis_st_cierra: PARENTESIS_CIERRA{printf(" ) ");};

valor: NOMBRE {
    struct node* aux;
    if((aux=find($1)) != NULL) {
        if(aux->type != 1){
            yyerror("La variable que se intento usar no es un numero");
            //fprintf(stderr, "Error en la linea %d. La variable que se intento usar no es un numero", yylineno);
            fprintf(stderr, "Error en alguna linea, capo. La variable que se intento asignar no existe");        
            YYABORT; 
        } else {
            printf("%s", $1);
        }
    } else {
            yyerror("La variable que se intento usar no existe");
            //fprintf(stderr, "Error en la linea %d. La variable que se intento usar no existe", yylineno);
            fprintf(stderr, "Error en alguna linea, capo. La variable que se intento asignar no existe");        
            YYABORT; 
    } };

    | NUMERO {printf("%d", $1);};
    | parentesis_st_abre operacion parentesis_st_cierra;

CONTROL_LOGICO: super_si | super_haz;

super_si: si_st sentencia_booleana entonces_haz CODE fin_si;

si_st: SI {printf("if(");};

entonces_haz: ':' {printf("){\n");};

fin_si: FIN {printf("}\n");} ;


super_haz:  haz_st ':' CODE fin_haz mientras_st sentencia_booleana fin_mientras;

haz_st: HAZ {printf("do{");};

fin_haz: FIN {printf("}\n");};

mientras_st: MIENTRAS {printf("while(");};

fin_mientras: FIN_LINEA {printf(");\n");};


sentencia_booleana: boolean
        |boolean sentencia_logica boolean
        |parentesis_st_abre sentencia_booleana parentesis_st_cierra sentencia_logica boolean
        |boolean sentencia_logica parentesis_st_abre sentencia_booleana parentesis_st_cierra
        |sentencia_not parentesis_st_abre sentencia_booleana parentesis_st_cierra
        |sentencia_not boolean
        |sentencia_comparativa;

sentencia_logica: Y {printf("&&");}
        | O {printf("||");};

sentencia_not: NO {printf("!");}
        | NO sentencia_not;

boolean: VERDADERO{printf("1");}
        | FALSO{printf("0");};

sentencia_comparativa: valor comparador valor;
                        
comparador: MENOR {printf("<");}
        | MAYOR {printf(">");}
        | MAYOR_IGUAL {printf(">=");}
        | MENOR_IGUAL {printf("<=");}
        | IGUAL{printf("==");};


%%


int main(void) {
    //list* symbolTable = (list*) malloc(sizeof(list));
    yyparse();
}