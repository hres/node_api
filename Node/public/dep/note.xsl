<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">
	<xsl:output encoding="UTF-8" indent="yes" method="xml" standalone="no" omit-xml-declaration="no"/>
	<xsl:template match="anagrafica">
		<html>
			<body>
				<h1>
					<font color="red">
						<xsl:value-of select="testata/nomemercato/@id"/>
					</font><xsl:value-of select="testata/nomemercato"/>
				</h1>
				<h2>
					<xsl:value-of select="testata/data"/>
				</h2>
				<hr/>
				<table bgcolor="yellow" border="1">
					<tbody>
						<tr>
							<th>Cod. Cliente</th>
							<th>Ragione Sociale</th>
							<th>Codice Fiscale/P.Iva</th>
							<th>Indirizzo</th>
						</tr>
						<xsl:for-each select="record">
							<tr>
								<td>
									<xsl:value-of select="codice_cliente"/>
								</td>
								<td>
									<xsl:value-of select="rag_soc"/>
								</td>
								<td>
									<xsl:value-of select="codice_fiscale"/>
								</td>
								<td>
									<xsl:value-of select="indirizzo"/>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
