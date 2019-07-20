/**
  BSD 3-Clause License

  Copyright (c) 2019, Odzhan. All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

  * Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <windows.h>
#include <ObjBase.h>
#include <ActivScp.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <inttypes.h>

#pragma comment(lib, "oleaut32.lib")
#pragma comment(lib, "ole32.lib")

typedef struct {
    IActiveScriptSite       site;
    IActiveScriptSiteWindow siteWnd; 
    ULONG                   m_cRef;
} MyIActiveScriptSite;

static STDMETHODIMP_(ULONG) AddRef(IActiveScriptSite *this);

static STDMETHODIMP QueryInterface(IActiveScriptSite *this, REFIID riid, void **ppv) {
    MyIActiveScriptSite *mas = (MyIActiveScriptSite*)this;

    if(ppv == NULL) return E_POINTER;
    
    // we implement the following interfaces
    if(IsEqualIID(&IID_IUnknown,          riid) || 
       IsEqualIID(&IID_IActiveScriptSite, riid)) 
    {
      *ppv = (LPVOID)this;
      AddRef(this);
      return S_OK;
    } 
    *ppv = NULL;
    return E_NOINTERFACE;
}

static STDMETHODIMP_(ULONG) AddRef(IActiveScriptSite *this) {
    MyIActiveScriptSite *mas = (MyIActiveScriptSite*)this;
  
    _InterlockedIncrement(&mas->m_cRef);
    return mas->m_cRef;
}

static STDMETHODIMP_(ULONG) Release(IActiveScriptSite *this) {
    MyIActiveScriptSite *mas = (MyIActiveScriptSite*)this;
    
    ULONG ulRefCount = _InterlockedDecrement(&mas->m_cRef);  
    return ulRefCount;
}

static STDMETHODIMP GetItemInfo(IActiveScriptSite *this, 
  LPCOLESTR objectName, DWORD dwReturnMask, 
  IUnknown **objPtr, ITypeInfo **ppti) 
{
    return S_OK;
}

static STDMETHODIMP OnScriptError(IActiveScriptSite *this, 
  IActiveScriptError *scriptError) 
{
    return S_OK;
}

static STDMETHODIMP GetLCID(IActiveScriptSite *this, LCID *plcid) {
    return S_OK;
}

static STDMETHODIMP GetDocVersionString(IActiveScriptSite *this, BSTR *version) {
    return S_OK;
}

static STDMETHODIMP OnScriptTerminate(IActiveScriptSite *this, 
  const VARIANT *pvr, const EXCEPINFO *pei) 
{
    return S_OK;
}

static STDMETHODIMP OnStateChange(IActiveScriptSite *this, SCRIPTSTATE state) {
    return S_OK;
}

static STDMETHODIMP OnEnterScript(IActiveScriptSite *this) {
    return S_OK;
}

static STDMETHODIMP OnLeaveScript(IActiveScriptSite *this) {
    return S_OK;
}

VOID run_script(PWCHAR lang, PCHAR script) {
    IActiveScriptParse     *parser;
    IActiveScript          *engine;
    MyIActiveScriptSite    mas;
    IActiveScriptSiteVtbl  vft;
    LPVOID                 cs;
    DWORD                  len;
    CLSID                  langId;
    HRESULT                hr;
    
    // 1. Initialize IActiveScript
    CLSIDFromProgID(lang, &langId);
    CoInitializeEx(NULL, COINIT_MULTITHREADED);
    
    CoCreateInstance(
      &langId, 0, CLSCTX_INPROC_SERVER, 
      &IID_IActiveScript, (void **)&engine);
    
    // 2. Query engine for script parser and initialize
    engine->lpVtbl->QueryInterface(
        engine, &IID_IActiveScriptParse, 
        (void **)&parser);
        
    parser->lpVtbl->InitNew(parser);
    
    // 3. Initialize IActiveScriptSite interface
    vft.QueryInterface      = (LPVOID)QueryInterface;
    vft.AddRef              = (LPVOID)AddRef;
    vft.Release             = (LPVOID)Release;
    vft.GetLCID             = (LPVOID)GetLCID;
    vft.GetItemInfo         = (LPVOID)GetItemInfo;
    vft.GetDocVersionString = (LPVOID)GetDocVersionString;
    vft.OnScriptTerminate   = (LPVOID)OnScriptTerminate;
    vft.OnStateChange       = (LPVOID)OnStateChange;
    vft.OnScriptError       = (LPVOID)OnScriptError;
    vft.OnEnterScript       = (LPVOID)OnEnterScript;
    vft.OnLeaveScript       = (LPVOID)OnLeaveScript;
    
    mas.site.lpVtbl     = (IActiveScriptSiteVtbl*)&vft;
    mas.siteWnd.lpVtbl  = NULL;
    mas.m_cRef          = 0;
    
    engine->lpVtbl->SetScriptSite(
        engine, (IActiveScriptSite *)&mas);
        
    // 4. Convert script to unicode and execute
    len = MultiByteToWideChar(
      CP_ACP, 0, script, -1, NULL, 0);
    
    len *= sizeof(WCHAR);
    
    cs = malloc(len);
    
    len = MultiByteToWideChar(
      CP_ACP, 0, script, -1, cs, len);
    
    parser->lpVtbl->ParseScriptText(
         parser, cs, 0, 0, 0, 0, 0, 0, 0, 0);  
    
    engine->lpVtbl->SetScriptState(
         engine, SCRIPTSTATE_CONNECTED);
    
    // 5. cleanup
    parser->lpVtbl->Release(parser);
    engine->lpVtbl->Close(engine);
    engine->lpVtbl->Release(engine);
    free(cs);
}

void *read_script(const char *path) {
    int         i;
    struct stat fs;
    FILE        *in;
    void        *data;
    
    // Script is inaccessibe? exit
    if(stat(path, &fs) != 0) return NULL;

    // Zero file size? exit
    if(fs.st_size == 0) return NULL;

    // Open script for reading
    in = fopen(path, "rb");
    if(in == NULL) return NULL;
    
    // allocate memory for script. plus 1 for null terminator
    data = calloc(fs.st_size, sizeof(char) + 1);
    if(data != NULL) {
      fread(data, sizeof(char), fs.st_size, in);
    } 
    fclose(in);
    return data;
}

int main(int argc, char *argv[]) {
    char    *path, *ext;
    void    *script;
    wchar_t *lang;
    
    if(argc != 2) {
      printf("usage: runscript <VBS | JS>\n");
      return 0;
    }
    
    path = argv[1];
    
    // assign correct language id depending on extension
    ext = strrchr(path, '.');
    
    if(!strcmpi(ext, ".js"))  lang = L"JScript";
    if(!strcmpi(ext, ".vbs")) lang = L"VBScript";
    
    if(lang == NULL) {
      printf("Uncognized extension.\n");
      return 0;
    }
    
    script = read_script(path);
    
    if(script == NULL) {
      printf("Unable to read file.\n");
      return 0;
    }
    run_scriptx(script);
    return 0;
}

