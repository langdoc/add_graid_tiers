<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- This XSL can be used with a command like this:
    
    java -jar ~/saxon9he.jar -s:file.eaf -xsl:add_graid_tiers.xsl -o:file-GRAID.eaf Participant=S1
    
    It is assumed that the file doesn't have GRAID tiers previously, and it does have otherwise normal
    ELAN file structure as used in Freiburg Research Group in Saami Studies.
    
    -->

        <xsl:param name="Participant" required="yes"/>
            
    <!-- Identity template, copies everything as is -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Override for target element -->

    <xsl:template match="ANNOTATION_DOCUMENT">


        <xsl:variable name="all_ids">
            <xsl:value-of select="//@ANNOTATION_ID"/>
        </xsl:variable>

        <xsl:variable name="num_id">
            <xsl:for-each select="$all_ids">
                <xsl:value-of select="replace($all_ids, 'a', '')"/>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="max_id">
            <xsl:value-of select="max(tokenize($num_id, ' '))"/>
        </xsl:variable>


        <!-- Copy the element -->

        <xsl:copy>

            <!-- And everything inside it -->

            <xsl:apply-templates select="@* | *"/>


            <!-- Let's make things a bit more complicated with GRAID orth tier, as it can have the orthT content with some regex.
                 What's going on here is that we pick all nodes from orthT tier and reuse them here. 
                 NOTE! May not work for several speaker, for-each has to be changed so that it picks only nodes from the current speaker -->

            <xsl:element name="TIER">
                <xsl:attribute name="LINGUISTIC_TYPE_REF" select="concat('GRAID', 'orthT')"/>
                <xsl:attribute name="PARENT_REF" select="concat('orth@', $Participant)"/>
                <xsl:attribute name="PARTICIPANT" select='$Participant'/>
                <xsl:attribute name="TIER_ID" select="concat('GRAIDorth@', $Participant)"/>
                <xsl:for-each
                    select="/ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='orthT' and @PARTICIPANT=$Participant]/ANNOTATION">
                    <xsl:element name="ANNOTATION">
                        <xsl:element name="REF_ANNOTATION">
                            <xsl:attribute name="ANNOTATION_ID">
                                <xsl:value-of select="concat('a', $max_id + position())"/>
                            </xsl:attribute>
                            <xsl:attribute name="ANNOTATION_REF">
                                <xsl:value-of select="./REF_ANNOTATION/@ANNOTATION_REF"/>
                            </xsl:attribute>
                            <xsl:element name="ANNOTATION_VALUE">
                                <xsl:value-of
                                    select="replace(./REF_ANNOTATION/ANNOTATION_VALUE/text(), '(\\A|\.|,|\?|!|:)', ' #')"
                                />
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>


            <!-- 
                
            <TIER LINGUISTIC_TYPE_REF="GRAIDorthT" PARENT_REF="orth@VIL-M-1985"
                PARTICIPANT="VIL-M-1985" TIER_ID="GRAIDorth@VIL-M-1985"/>
           
            -->

            <!--            <xsl:element name="TIER">
                <xsl:attribute name="LINGUISTIC_TYPE_REF">
                    <xsl:value-of select="'GRAIDwordT'"/>
                </xsl:attribute>
                <xsl:attribute name="PARENT_REF">
                    <xsl:value-of select="'GRAIDorth@{$Participant}'"/>
                </xsl:attribute>
                <xsl:attribute name="PARTICIPANT">
                    <xsl:value-of select="'{$Participant}'"/>
                </xsl:attribute>
                <xsl:attribute name="TIER_ID">
                    <xsl:value-of select="'GRAIDword@{$Participant}'"/>
                </xsl:attribute>
                <xsl:for-each
                    select="/ANNOTATION_DOCUMENT/TIER[@LINGUISTIC_TYPE_REF='wordT']/ANNOTATION">
                    <xsl:element name="ANNOTATION">
                        <xsl:element name="REF_ANNOTATION">
                            <xsl:attribute name="ANNOTATION_ID">
                                <xsl:value-of select="concat('a', $max_id + position())"/>
                            </xsl:attribute>
                            <xsl:attribute name="ANNOTATION_REF">
                                <xsl:value-of select="./REF_ANNOTATION/@ANNOTATION_REF"/>
                            </xsl:attribute>
                            <xsl:element name="ANNOTATION_VALUE">
                                <xsl:value-of
                                    select="replace(./REF_ANNOTATION/ANNOTATION_VALUE/text(), '(\\A|\.|,|\?|!|:)', ' #')"
                                />
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
-->


            <!-- This adds the GRAID tiers themselves -->

            <TIER LINGUISTIC_TYPE_REF="GRAIDwordT" PARENT_REF="GRAIDorth@{$Participant}"
                PARTICIPANT="{$Participant}" TIER_ID="GRAIDword@{$Participant}"/>

            <TIER LINGUISTIC_TYPE_REF="GRAIDformT" PARENT_REF="GRAIDword@{$Participant}"
                PARTICIPANT="{$Participant}" TIER_ID="GRAIDform@{$Participant}"/>
            <TIER LINGUISTIC_TYPE_REF="GRAIDfunctT" PARENT_REF="GRAIDword@{$Participant}"
                PARTICIPANT="{$Participant}" TIER_ID="GRAIDfunct@{$Participant}"/>
            <TIER LINGUISTIC_TYPE_REF="GRAIDcommentT" PARENT_REF="GRAIDorth@{$Participant}"
                PARTICIPANT="{$Participant}" TIER_ID="GRAIDcomment"/>

            <!--    This adds the linguistic types -->

            <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association" GRAPHIC_REFERENCES="false"
                LINGUISTIC_TYPE_ID="GRAIDorthT" TIME_ALIGNABLE="false"/>
            <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Subdivision" GRAPHIC_REFERENCES="false"
                LINGUISTIC_TYPE_ID="GRAIDwordT" TIME_ALIGNABLE="false"/>
            <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association" GRAPHIC_REFERENCES="false"
                LINGUISTIC_TYPE_ID="GRAIDcommentT" TIME_ALIGNABLE="false"/>
            <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association"
                CONTROLLED_VOCABULARY_REF="GRAIDform" GRAPHIC_REFERENCES="false"
                LINGUISTIC_TYPE_ID="GRAIDformT" TIME_ALIGNABLE="false"/>
            <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association"
                CONTROLLED_VOCABULARY_REF="GRAIDfunct" GRAPHIC_REFERENCES="false"
                LINGUISTIC_TYPE_ID="GRAIDfunctT" TIME_ALIGNABLE="false"/>
            <LINGUISTIC_TYPE CONSTRAINTS="Symbolic_Association" GRAPHIC_REFERENCES="false"
                LINGUISTIC_TYPE_ID="GRAIDwfwT" TIME_ALIGNABLE="false"/>

            <!-- This adds the controlled vocabularies -->

            <xsl:element name="CONTROLLED_VOCABULARY">
                <xsl:attribute name="CV_ID">GRAIDfunct</xsl:attribute>
                <DESCRIPTION LANG_REF="und"
                    >Word-for-word glosses following the GRAID annotation system.</DESCRIPTION>
                <CV_ENTRY_ML CVE_ID="cveid0">
                    <CVE_VALUE DESCRIPTION="subject of intransitive clause" LANG_REF="und"
                        >s</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid1">
                    <CVE_VALUE DESCRIPTION="subject of transitive clause" LANG_REF="und"
                        >a</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid2">
                    <CVE_VALUE DESCRIPTION="object of transitive clause" LANG_REF="und"
                        >p</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid3">
                    <CVE_VALUE DESCRIPTION="goal argument or adjunct, also addressee or recipient"
                        LANG_REF="und">g</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid4">
                    <CVE_VALUE DESCRIPTION="locative (also: source) argument or adjunct"
                        LANG_REF="und">l</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid5">
                    <CVE_VALUE
                        DESCRIPTION="oblique argument, but not a goal or locative (g and l are used for them)"
                        LANG_REF="und">obl</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid6">
                    <CVE_VALUE DESCRIPTION="secondary object" LANG_REF="und">p2</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid7">
                    <CVE_VALUE DESCRIPTION="possessor" LANG_REF="und">poss</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid8">
                    <CVE_VALUE DESCRIPTION="other function" LANG_REF="und">other</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid9">
                    <CVE_VALUE DESCRIPTION="dislocated topic" LANG_REF="und">dt</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid10">
                    <CVE_VALUE DESCRIPTION="dislocated topic, corresponding to transitive subject"
                        LANG_REF="und">dta</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid11">
                    <CVE_VALUE DESCRIPTION="dislocated topic, corresponding to transitive object"
                        LANG_REF="und">dtp</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid12">
                    <CVE_VALUE DESCRIPTION="dislocated topic, corresponding to intransitive subject"
                        LANG_REF="und">dts</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid13">
                    <CVE_VALUE DESCRIPTION="predicate" LANG_REF="und">pred</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid14">
                    <CVE_VALUE DESCRIPTION="existential predicate ('there is')" LANG_REF="und"
                        >predex</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid15">
                    <CVE_VALUE DESCRIPTION="no function on clause level" LANG_REF="und"
                        >--</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid16">
                    <CVE_VALUE DESCRIPTION="apposition" LANG_REF="und">appos</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid17">
                    <CVE_VALUE DESCRIPTION="coordinate element with s function" LANG_REF="und"
                        >cons</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid18">
                    <CVE_VALUE DESCRIPTION="coordinate element with a function" LANG_REF="und"
                        >cona</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid19">
                    <CVE_VALUE DESCRIPTION="coordinate element with p function" LANG_REF="und"
                        >conp</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid20">
                    <CVE_VALUE DESCRIPTION="coordinate element with nonspecified function"
                        LANG_REF="und">con</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid21">
                    <CVE_VALUE
                        DESCRIPTION="subject of intransitive clause with a predicate introducing direct speech"
                        LANG_REF="und">s_ds</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid22">
                    <CVE_VALUE
                        DESCRIPTION="locational predicate (especially for non-verbal predicates, as in HE IS IN THE GARDEN)"
                        LANG_REF="und">pred_l</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid23">
                    <CVE_VALUE
                        DESCRIPTION="dislocated topic, corresponding to goal, recipient or addressee"
                        LANG_REF="und">dtg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid24">
                    <CVE_VALUE DESCRIPTION="coordinate element with g function" LANG_REF="und"
                        >cong</CVE_VALUE>
                </CV_ENTRY_ML>
            </xsl:element>
            <xsl:element name="CONTROLLED_VOCABULARY">
                <xsl:attribute name="CV_ID">GRAIDform</xsl:attribute>
                <DESCRIPTION LANG_REF="und"
                    >Word-for-word glosses following the GRAID annotation system.</DESCRIPTION>
                <CV_ENTRY_ML CVE_ID="cveid0">
                    <CVE_VALUE
                        DESCRIPTION="covert argument / unfilled argument position with third person nonhuman referent"
                        LANG_REF="und">0</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid1">
                    <CVE_VALUE
                        DESCRIPTION="covert argument / unfilled argument position with first person referent"
                        LANG_REF="und">0.1</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid2">
                    <CVE_VALUE
                        DESCRIPTION="covert argument / unfilled argument position with second person referent"
                        LANG_REF="und">0.2</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid3">
                    <CVE_VALUE
                        DESCRIPTION="covert argument / unfilled argument position with human referent"
                        LANG_REF="und">0.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid4">
                    <CVE_VALUE
                        DESCRIPTION="covert argument / unfilled argument position with nonhuman, anthropomorphized referent"
                        LANG_REF="und">0.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid5">
                    <CVE_VALUE
                        DESCRIPTION="'weak' clitic pronoun with third person nonhuman referent"
                        LANG_REF="und">=pro</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid6">
                    <CVE_VALUE DESCRIPTION="'weak' clitic pronoun with first person referent"
                        LANG_REF="und">=pro.1</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid7">
                    <CVE_VALUE DESCRIPTION="'weak' clitic pronoun with second person referent"
                        LANG_REF="und">=pro.2</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid8">
                    <CVE_VALUE DESCRIPTION="'weak' clitic pronoun with human referent"
                        LANG_REF="und">=pro.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid9">
                    <CVE_VALUE
                        DESCRIPTION="'weak' clitic pronoun with nonhuman, anthropomorphized referent"
                        LANG_REF="und">=pro.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid10">
                    <CVE_VALUE
                        DESCRIPTION="'weak', phonologically lighter pronoun with third person nonhuman referent"
                        LANG_REF="und">wpro</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid11">
                    <CVE_VALUE
                        DESCRIPTION="'weak', phonologically lighter pronoun with first person referent"
                        LANG_REF="und">wpro.1</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid12">
                    <CVE_VALUE
                        DESCRIPTION="'weak', phonologically lighter pronoun with second person referent"
                        LANG_REF="und">wpro.2</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid13">
                    <CVE_VALUE
                        DESCRIPTION="'weak', phonologically lighter pronoun with human referent"
                        LANG_REF="und">wpro.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid14">
                    <CVE_VALUE
                        DESCRIPTION="'weak', phonologically lighter pronoun with nonhuman, anthropomorphized referent"
                        LANG_REF="und">wpro.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid15">
                    <CVE_VALUE
                        DESCRIPTION="free pronoun in full form with third person nonhuman referent"
                        LANG_REF="und">pro</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid16">
                    <CVE_VALUE DESCRIPTION="free pronoun in full form with first person referent"
                        LANG_REF="und">pro.1</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid17">
                    <CVE_VALUE DESCRIPTION="free pronoun in full form with second person referent"
                        LANG_REF="und">pro.2</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid18">
                    <CVE_VALUE DESCRIPTION="free pronoun in full form with human referent"
                        LANG_REF="und">pro.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid19">
                    <CVE_VALUE
                        DESCRIPTION="free pronoun in full form with nonhuman, anthropomorphized referent"
                        LANG_REF="und">pro.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid20">
                    <CVE_VALUE DESCRIPTION="reflexive or reciprocal pronoun" LANG_REF="und"
                        >refl_pro</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid21">
                    <CVE_VALUE DESCRIPTION="head of noun phrase with nonhuman referent"
                        LANG_REF="und">np</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid22">
                    <CVE_VALUE DESCRIPTION="head of noun phrase with human referent" LANG_REF="und"
                        >np.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid23">
                    <CVE_VALUE
                        DESCRIPTION="head of noun phrase with nonhuman, anthropomorphized referent"
                        LANG_REF="und">np.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid24">
                    <CVE_VALUE DESCRIPTION="proper noun with nonhuman referent" LANG_REF="und"
                        >pn_np</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid25">
                    <CVE_VALUE DESCRIPTION="proper noun with human referent" LANG_REF="und"
                        >pn_np.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid26">
                    <CVE_VALUE DESCRIPTION="proper noun with nonhuman, anthropomorphized referent"
                        LANG_REF="und">pn_np.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid27">
                    <CVE_VALUE DESCRIPTION="nonreferential pronoun" LANG_REF="und">xpro</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid28">
                    <CVE_VALUE
                        DESCRIPTION="subconstituent of an NP, occurring to the left of the head"
                        LANG_REF="und">ln</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid29">
                    <CVE_VALUE DESCRIPTION="numeral within an NP, occurring to the left of the head"
                        LANG_REF="und">ln_num</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid30">
                    <CVE_VALUE
                        DESCRIPTION="attributive adjective within an NP, occurring to the left of the head"
                        LANG_REF="und">ln_adj</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid31">
                    <CVE_VALUE
                        DESCRIPTION="demonstrative, occurring to the left of its nominal head"
                        LANG_REF="und">ln_dem</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid32">
                    <CVE_VALUE
                        DESCRIPTION="head of an NP with a non-human referent, within another NP, with the embedded NP occurring to the left of the head"
                        LANG_REF="und">ln_np</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid33">
                    <CVE_VALUE
                        DESCRIPTION="head of an NP with a human referent, within another NP, with the embedded NP occurring to the left of the head"
                        LANG_REF="und">ln_np.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid34">
                    <CVE_VALUE
                        DESCRIPTION="head of an NP with a non-human anthropomorphized referent, within another NP, with the embedded NP occurring to the left of the head"
                        LANG_REF="und">ln_np.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid35">
                    <CVE_VALUE
                        DESCRIPTION="pronoun with a nonhuman referent within an NP, the pronoun occurring to the left of the head"
                        LANG_REF="und">ln_pro</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid36">
                    <CVE_VALUE
                        DESCRIPTION="pronoun with a human referent within an NP, the pronoun occurring to the left of the head"
                        LANG_REF="und">ln_pro.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid37">
                    <CVE_VALUE
                        DESCRIPTION="pronoun with a nonhuman, anthropomorphized referent within an NP, the pronoun occurring to the left of the head"
                        LANG_REF="und">ln_pro.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid38">
                    <CVE_VALUE
                        DESCRIPTION="subconstituent of an NP, occurring to the right of the head"
                        LANG_REF="und">rn</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid39">
                    <CVE_VALUE
                        DESCRIPTION="head of an NP with a non-human referent that is a subconstituent of another noun phrase, with the embedded NP occurring to the right of the head noun"
                        LANG_REF="und">rn_np</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid40">
                    <CVE_VALUE
                        DESCRIPTION="head of an NP with a human referent that is a subconstituent of another noun phrase, with the embedded NP occurring to the right of the head noun"
                        LANG_REF="und">rn_np.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid41">
                    <CVE_VALUE DESCRIPTION="full verb" LANG_REF="und">v</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid42">
                    <CVE_VALUE DESCRIPTION="verb of motion" LANG_REF="und">mot_v</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid43">
                    <CVE_VALUE DESCRIPTION="verb of caused motion" LANG_REF="und"
                        >causmot_v</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid44">
                    <CVE_VALUE DESCRIPTION="verb of speech" LANG_REF="und">say_v</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid45">
                    <CVE_VALUE DESCRIPTION="verb of transfer of possession" LANG_REF="und"
                        >give_v</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid46">
                    <CVE_VALUE DESCRIPTION="auxiliary" LANG_REF="und">aux</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid47">
                    <CVE_VALUE DESCRIPTION="clitic auxiliary" LANG_REF="und">=aux</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid48">
                    <CVE_VALUE DESCRIPTION="overt copular verb" LANG_REF="und">cop</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid49">
                    <CVE_VALUE DESCRIPTION="clitic copular verb" LANG_REF="und">=cop</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid50">
                    <CVE_VALUE
                        DESCRIPTION="non-canonical verb form (as in converb or participial constructions)"
                        LANG_REF="und">vother</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid51">
                    <CVE_VALUE
                        DESCRIPTION="element within the verb phrase, occurring to the left of the head"
                        LANG_REF="und">lv</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid52">
                    <CVE_VALUE
                        DESCRIPTION="element within the verb phrase, occurring to the right of the head"
                        LANG_REF="und">rv</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid53">
                    <CVE_VALUE DESCRIPTION="reflexive or reciprocal element (not a pronoun)"
                        LANG_REF="und">refl</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid54">
                    <CVE_VALUE DESCRIPTION="adposition (preposition by default)" LANG_REF="und"
                        >adp</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid55">
                    <CVE_VALUE DESCRIPTION="coordinating clausal conjunction" LANG_REF="und"
                        >ccon</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid56">
                    <CVE_VALUE DESCRIPTION="subordinating clausal conjunction" LANG_REF="und"
                        >csub</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid57">
                    <CVE_VALUE DESCRIPTION="phrasal coordinator" LANG_REF="und">coo</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid58">
                    <CVE_VALUE DESCRIPTION="element not covered by the other glosses" LANG_REF="und"
                        >other</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid59">
                    <CVE_VALUE DESCRIPTION="main clause" LANG_REF="und">##</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid60">
                    <CVE_VALUE DESCRIPTION="main clause with negative polarity" LANG_REF="und"
                        >##neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid61">
                    <CVE_VALUE DESCRIPTION="main clause in direct speech" LANG_REF="und"
                        >##ds</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid62">
                    <CVE_VALUE DESCRIPTION="main clause with negative polarity in direct speech"
                        LANG_REF="und">##ds.neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid63">
                    <CVE_VALUE DESCRIPTION="adverbial clause" LANG_REF="und">#ac</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid64">
                    <CVE_VALUE DESCRIPTION="adverbial clause with negative polarity" LANG_REF="und"
                        >#ac.neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid65">
                    <CVE_VALUE DESCRIPTION="adverbial clause in direct speech" LANG_REF="und"
                        >#ds_ac</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid66">
                    <CVE_VALUE
                        DESCRIPTION="adverbial clause with negative polarity in direct speech"
                        LANG_REF="und">#ds_ac.neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid67">
                    <CVE_VALUE DESCRIPTION="complement clause" LANG_REF="und">#cc</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid68">
                    <CVE_VALUE DESCRIPTION="complement clause with negative polarity" LANG_REF="und"
                        >#cc.neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid69">
                    <CVE_VALUE DESCRIPTION="complement clause in direct speech" LANG_REF="und"
                        >#ds_cc</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid70">
                    <CVE_VALUE
                        DESCRIPTION="complement clause with negative polarity in direct speech"
                        LANG_REF="und">#ds_cc.neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid71">
                    <CVE_VALUE DESCRIPTION="relative clause" LANG_REF="und">#rc</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid72">
                    <CVE_VALUE DESCRIPTION="relative clause with negative polarity" LANG_REF="und"
                        >#rc.neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid73">
                    <CVE_VALUE DESCRIPTION="relative clause in direct speech" LANG_REF="und"
                        >#ds_rc</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid74">
                    <CVE_VALUE DESCRIPTION="relative clause with negative polarity in direct speech"
                        LANG_REF="und">#ds_rc.neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid75">
                    <CVE_VALUE
                        DESCRIPTION="embedded/dependent clause of unspecified type (also used for coordinate clauses)"
                        LANG_REF="und">#</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid76">
                    <CVE_VALUE
                        DESCRIPTION="embedded/dependent clause of unspecified type (also used for coordinate clauses) with negative polarity"
                        LANG_REF="und">#neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid77">
                    <CVE_VALUE
                        DESCRIPTION="embedded/dependent clause of unspecified type (also used for coordinate clauses) in direct speech"
                        LANG_REF="und">#ds</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid78">
                    <CVE_VALUE
                        DESCRIPTION="embedded/dependent clause of unspecified type (also used for coordinate clauses) with negative polarity in direct speech"
                        LANG_REF="und">#ds.neg</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid79">
                    <CVE_VALUE DESCRIPTION="end of embedded clause, what follows is a main clause"
                        LANG_REF="und">%</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid80">
                    <CVE_VALUE
                        DESCRIPTION="clause or section of speech that is not considered for analysis"
                        LANG_REF="und">#nc</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid81">
                    <CVE_VALUE
                        DESCRIPTION="coordinator within an NP (also within one NP consisting of two coordinated NPs), occurring to the left of the NP's head"
                        LANG_REF="und">ln_coo</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid82">
                    <CVE_VALUE DESCRIPTION="postposition" LANG_REF="und">pop_adp</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid83">
                    <CVE_VALUE DESCRIPTION="interrogative pronoun with expected nonhuman referent"
                        LANG_REF="und">wh_pro</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid84">
                    <CVE_VALUE DESCRIPTION="interrogative pronoun with expected human referent"
                        LANG_REF="und">wh_pro.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid85">
                    <CVE_VALUE
                        DESCRIPTION="interrogative demonstrative article ('which ...?'), standing to the left of the head noun"
                        LANG_REF="und">wh_ln_dem</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid86">
                    <CVE_VALUE
                        DESCRIPTION="head of an NP with a non-human anthropomorphized referent, within another NP, with the embedded NP occurring to the right of the head"
                        LANG_REF="und">rn_np.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid87">
                    <CVE_VALUE
                        DESCRIPTION="pronoun with a nonhuman referent within an NP, the pronoun occurring to the right of the head"
                        LANG_REF="und">rn_pro</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid88">
                    <CVE_VALUE
                        DESCRIPTION="pronoun with a human referent within an NP, the pronoun occurring to the right of the head"
                        LANG_REF="und">rn_pro.h</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid89">
                    <CVE_VALUE
                        DESCRIPTION="pronoun with a nonhuman, anthropomorphized referent within an NP, the pronoun occurring to the right of the head"
                        LANG_REF="und">rn_pro.d</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid90">
                    <CVE_VALUE
                        DESCRIPTION="numeral within an NP, occurring to the right of the head"
                        LANG_REF="und">rn_num</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid91">
                    <CVE_VALUE
                        DESCRIPTION="attributive adjective within an NP, occurring to the right of the head"
                        LANG_REF="und">rn_adj</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid92">
                    <CVE_VALUE
                        DESCRIPTION="demonstrative, occurring to the right of its nominal head"
                        LANG_REF="und">rn_dem</CVE_VALUE>
                </CV_ENTRY_ML>
                <CV_ENTRY_ML CVE_ID="cveid93">
                    <CVE_VALUE
                        DESCRIPTION="coordinator within an NP (also within one NP consisting of two coordinated NPs), occurring to the right of the NP's head"
                        LANG_REF="und">rn_coo</CVE_VALUE>
                </CV_ENTRY_ML>
            </xsl:element>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
