%{
    #include <string.h>
    #include <errno.h>

    #include "fwstub_yacc.h"
    #include "fwstub_log.h"
    #include "utils.h"
	
    void fwstuberror(char *);
    void fwstub_report_error(char *fmt, ...);
    static void exclude_file();
    int fwstub_include_file(const char *filename);
    void fwstub_free_istack();
    inline int fwstub_getlineno();
    inline const char* fwstub_getfilename();
    static inline void linenoplusplus();
    inline const char *fwstub_get_basedir();

    struct _keyword {
        char *kw_name;
        int kw_token;
    };

    #define MAX_INCLUDE_DEPTH 10

    struct _input_buffer {
	YY_BUFFER_STATE buffer;
	char *filename;
	FILE *filein;
	int lineno;
    };

    /* stack to store nested/included files */
    static struct _input_buffer istack[MAX_INCLUDE_DEPTH];
    static int nistack = 0;

    #ifndef min
    #define min(a,b) (((a) < (b)) ? (a) : (b))
    #endif

    static struct _keyword keywords[] = {
	{ "ip-fwtype-map", KW_IPFWTYPEMAP},
	{ "ip-fwtype",	KW_IPFWTYPE},
	{ "key-value",	KW_KEYVALUE},
	{ "delimiter", KW_DELIMITER},
	{ "word-boundry", KW_WORD_BOUNDRY},
	{ "keyval-seperator", KW_KEYVAL_SEPERATOR},
	{ "keyval-pair", KW_KEYVAL_PAIR},
	{ "regex", KW_REGEX},
	{ "idregex", KW_IDREGEX},
	{ "idmap", KW_ID_MAP},
	{ "idmap-key", KW_ID_MAP_KEY},
	{ "idmap-value", KW_ID_MAP_VALUE},

	/* on/off switches */
	{ "yes",		KW_YES },
	{ "on",			KW_YES },
	{ "no",			KW_NO },
	{ "off",		KW_NO }

    };

    #define MAX_REGEXP_LEN  (25*1024)

    static char tiny_buf[MAX_REGEXP_LEN];
    static char *tiny_str;
    static int check_reserved_words(const char *token);
    static void append_string(int length, unsigned char *str);
    static void append_char(unsigned char c);
%}

word		[^ \#'"\(\)\{\}\*\:\n\t,><&|!=]
digit           [0-9]

%x incl
%x string
/* Don't emit a fwstubunput function in the generated scanner.  */
%option nounput

%%
"/*"			{
			    register int c;

			    for ( ; ; ) {
				while ( (c = input()) != '*' && c != EOF ) {
				    /* eat up text of comment */
				    if(c == '\n')
					linenoplusplus();
				}

				if ( c == '*' ) {
				    while ( (c = input()) == '*' );
				    if ( c == '/' )
					break;    /* found the end */
				    if(c == '\n')
					linenoplusplus();
				}

				if ( c == EOF ) {
				    fwstuberror( "EOF in comment" );
				    break;
				}
			    }
			}

include			BEGIN(incl);
<incl>[ \t]*\"		/* eat the whitespace and reach to quotes */
<incl>[^"]+\"		{
			    fwstubtext[strlen(fwstubtext)-1] = '\0';
                            /* if file fails to include, we'll continue with current file, but
                             * if the include-stack overflows, we will abort. KW_INCLUDE is not
                             * handled in yacc and so it will abort with unexpected identifier.
                             */
			    if(*fwstubtext == '/') {
				/* full path */
				if(fwstub_include_file(fwstubtext) == -1) {
				    return KW_INCLUDE;
				}
			    } else {
				/* relative path */
				char filepath[1024];
				snprintf(filepath, sizeof(filepath), "%s/%s", fwstub_get_basedir(), fwstubtext);
				if(fwstub_include_file(filepath) == -1) {
				    return KW_INCLUDE;
				}
			    }
			    BEGIN(INITIAL);
			}


({digit}{1,3}\.){3}{digit}{1,3}\-({digit}{1,3}\.){3}{digit}{1,3} {
							fwstublval.cptr = strdup(fwstubtext);
							return IPV4_RANGE;
						}
({digit}{1,3}\.){3}{digit}{1,3}\/({digit}{1,3}\.){3}{digit}{1,3} {
							fwstublval.cptr = strdup(fwstubtext);
							return IPV4_NETWORK;
						}
({digit}{1,3}\.){3}{digit}{1,3}\/{digit}+ 	{
							fwstublval.cptr = strdup(fwstubtext);
							return IPV4_CIDRNETWORK;
						}
({digit}{1,3}\.){3}{digit}{1,3} 		{
							fwstublval.cptr = strdup(fwstubtext);
							return IPV4_ADDRESS;
						}

0x{digit}+		{ fwstublval.num = strtol(fwstubtext, NULL, 16); return NUMBER; }
0{digit}+		{ fwstublval.num = strtol(fwstubtext, NULL, 8 ); return NUMBER; }
{digit}+		{ fwstublval.num = strtol(fwstubtext, NULL, 10); return NUMBER; }


{word}+			{
			return check_reserved_words(fwstubtext);
			}

[&\|!\(\)=\{\}<>:]	{ return *fwstubtext; }

[\n]			{ linenoplusplus(); return '\n';}
[ \t\r]			;  /* skip whitespace */

"#"			{
				register int c;
				while ( (c = input()) !=  EOF ) {
					if(c=='\n') {
						linenoplusplus();
						break;
					}
				}
				;    /* eat up text of comment */
			}

\"			{
				tiny_str = tiny_buf;
				BEGIN(string);
                        }
<string>\\a		{ append_char(7); }
<string>\\n		{ append_char(10); }
<string>\\r		{ append_char(13); }
<string>\\t		{ append_char(9); }
<string>\\v		{ append_char(11); }
<string>\\[^anrtv]	{ append_string(1, (unsigned char*)(fwstubtext + 1)); }
<string>\"		{
				BEGIN(INITIAL);
				fwstublval.cptr = strdup(tiny_buf);
				tiny_buf[0] = '\0';
				return STRING;
			}
<string>[^"\\]+		{ append_string(strlen(fwstubtext), (unsigned char*)fwstubtext); }

<<EOF>>			{
				if(nistack == 1) {
				    /* we are here because we have reached the EOF of root-file,
				     * we are not freeing the root-file buffer from here, as that
				     * would be freed in parse_conf_file, which does this
				     * by calling free_istack.
				     */
				    yyterminate();
				}
				exclude_file();
			}

%%

int fwstubwrap(void)
{
    return 1;
}

static int
check_reserved_words(const char *token)
{
    int i;

    fwstublval.cptr = 0;
    for (i = 0; i < (sizeof(keywords) / sizeof(struct _keyword)); i++) {
	if (strcasecmp(keywords[i].kw_name, token) == 0) {
	    return keywords[i].kw_token;
	}
    }
    fwstublval.cptr = strdup(token);
    return IDENTIFIER;
}

static void
append_string(int length, unsigned char *s)
{
    int to_copy = min(MAX_REGEXP_LEN - (tiny_str - tiny_buf) - 1, length);

    if(length != to_copy) {
	fwstub_report_error("String length exceeds maximum allowed size (%d character)."\
			" Proxy will continue with partial string, "\
			"BEWARE, this can cause proxy to misbehave.", MAX_REGEXP_LEN);
    }
    memcpy(tiny_str, s, to_copy);
    tiny_str += to_copy;
    *tiny_str = 0;
}

static void
append_char(unsigned char c)
{
    append_string(1, &c);
}

void
fwstub_lex_flush()
{
    xassert(nistack == 0);
    /* we need not do YY_FLUSH_BUFFER as we create a new buffer
     * for every file that we open.
     */
}

static void
free_input_buffer(struct _input_buffer * const ib)
{   
    xassert(ib != NULL);
    fclose(ib->filein);
    yy_flush_buffer(ib->buffer);
    fwstub_delete_buffer(ib->buffer);
    free(ib->filename);
}

inline int
fwstub_getlineno()
{
    xassert(nistack > 0);
    return istack[nistack-1].lineno;
}

inline const char*
fwstub_getfilename()
{
    xassert(nistack > 0);
    return istack[nistack-1].filename;
}

static inline void
linenoplusplus()
{
    xassert(nistack > 0);
    ++istack[nistack-1].lineno;
}

/* returns -1 if stack-overflow
 * returns  1 if failed to open file.
 * returns  0 on success
 */
int
fwstub_include_file(const char *filename)
{
    FILE *file;

    if(nistack > 0) {
	fwstub_log_message(FWSLG_INFO, "Include file '%s' from '%s:%d'\n", filename, 
										fwstub_getfilename(), fwstub_getlineno());
    } else {
	fwstub_log_message(FWSLG_INFO, "Open file '%s'\n", filename);
    }

    if(nistack >= MAX_INCLUDE_DEPTH) {
	fwstub_log_message(FWSLG_ERR, "Includes nested too deeply (depth exceeds %d)\n",
							MAX_INCLUDE_DEPTH);
	return -1;
    }

    file = fopen(filename, "r");
    if(!file) {
	fwstub_log_message(FWSLG_ERR, "fopen(%s) failed: %s\n", filename, strerror(errno));
	return 1;
    }
    memset(&istack[nistack], 0, sizeof(struct _input_buffer));
    istack[nistack].buffer = fwstub_create_buffer( file, YY_BUF_SIZE );
    istack[nistack].filename = strdup(filename);
    istack[nistack].lineno = 1;
    istack[nistack].filein = file;
    fwstubin = file;
    fwstub_switch_to_buffer(istack[nistack].buffer);
    ++nistack;
    return 0;
}

static void
exclude_file()
{
    /* we should not exclude the root-file */
    xassert(nistack > 1);
    fwstub_log_message(FWSLG_INFO, "Exclude file '%s'\n", fwstub_getfilename());
    --nistack;
    free_input_buffer(&istack[nistack]);
    fwstub_switch_to_buffer(istack[nistack-1].buffer);
    fwstubin = istack[nistack-1].filein;
}

void
fwstub_free_istack()
{
    int i;
    for(i=0; i<nistack; i++) {
        free_input_buffer(&istack[i]);
    }
    nistack = 0;
}
