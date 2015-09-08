## Adding GRAID tiers

This XSL is developed for adding GRAID tiers to ELAN files. The idea is that GRAID tiers usually are set up later, as they are not part of the default tier configuration used in Freiburg Research Group in Saami Studies. Beside this they are also often set up for one speaker only. As an example, if the session contains a story or other coherent narrative, it makes sense to set up this kind of heavy tier structure for the actual speaker, and not for the linguist or archiver or whoever other marginal participant there is present in the file.

The XSL takes one command line argument, which is the name of the participant. If this participant is not present, no changes are done. When the participant is found, the GRAID tiers are set up to their places. Also the right Controlled Vocabularies are inserted to the file.

### Example

This example assumes that the computer has Saxon XSL engine in the home directory.

    java -jar -i:test.eaf -xsl:add_graid_tiers.xsl -o:test_graid.eaf

The old ELAN file can be deleted after the GRAID tiers have been inserted, but at least for now I don't want to make those changes in place, but prefer doing another file. Especially in the case like this, where the change is not really that often needed and doesn't need to be repeated for a large number of files at once.
