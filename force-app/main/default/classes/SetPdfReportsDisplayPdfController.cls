public class SetPdfReportsDisplayPdfController
{

public SetPdfReportsDisplayPdfController()
{
string documentid = ApexPages.currentPage().getParameters().get('id');
d1=[select id, name, body from document where id=:documentid];
}
public string pdfcontent{get;set;}
public  document d1;
public string docname { get; set; }
public void DispalyPDFMethod ()
{
    string documentid = ApexPages.currentPage().getParameters().get('id'); 
    d1=[select id, name, body from document where id=:documentid];
    
    system.debug('%%%%%%%%%'+d1);

        docname = d1.name;
    blob b1=d1.body;    
        pdfcontent = '/servlet/servlet.FileDownload?file='+d1.id;
    }
    
   
}