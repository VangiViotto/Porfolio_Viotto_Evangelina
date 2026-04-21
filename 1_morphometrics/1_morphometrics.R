
# Libraries
library(geomorph)
library(readxl)
library(dplyr)
library(ggplot2)
library(MASS)
library(viridis)

# ==============================/
# 1. Load and clean data----
# ==============================/

datos_sim<- read.csv("simulated_metadata.CSV")


datos_sim<- datos_sim %>%
  mutate(
    Sexo = ifelse(Sexo == "Hembra", "Female", "Male"),
    Sexo = as.factor(Sexo),
    clust = as.factor(clust),
    Sitio = as.factor(Sitio)
  )

# Keep individuals with complete landmark sets
datos_SD <- datos_sim %>%
  filter(!is.na(SD_a) & !is.na(SD_b) & !is.na(SD_c))

IDs_SD <- datos_SD$Num_imagen

# ==============================/
# 2. Load landmarks----
# ==============================/

coords_raw <-readland.tps("simulated_landmarks.TPS",
                   specID = "ID",
                   readcurves = FALSE)# readland.tps("data/SD.tps", specID = "ID")

# ==============================/
# 3. Generalized Procrustes Analysis----
# ==============================/

# Align shapes (remove size, rotation, translation)
gpa <- gpagen(coords_raw)

# ==============================/
# 4. Average replicates----
# ==============================/

# Replicate IDs (3 digitizations per individual)
ID_rep <- rep(IDs_SD, 3)

# Average replicates to obtain one shape per individual
coords_mean <- coords.subset(gpa$coords, group = ID_rep)
coords_mean <- simplify2array(lapply(coords_mean, mshape))

# Extract centroid size
CS <- gpa$Csize[1:length(IDs_SD)]

# ==============================/
# 5. PCA----
# ==============================/

# PCA on mean shapes
pca <- gm.prcomp(coords_mean)

scores <- as.data.frame(pca$x)
scores$Sexo <- datos_SD$Sexo
scores$clust <- datos_SD$clust
scores$Sitio <- datos_SD$Sitio
scores$ID <- datos_SD$Num_imagen

# Variance explained by PCs
var_exp <- round(pca$d / sum(pca$d) * 100, 2)

# ==============================/
# 6. Statistical models----
# ==============================/

# Shape differences by sex
modelo_sexo <- procD.lm(coords_mean ~ Sexo,
                        data = datos_SD,
                        iter = 999)

# Shape differences by clust
modelo_clust <- procD.lm(coords_mean ~ clust,
                        data = datos_SD,
                        iter = 999)


# Size differences by sex
modelo_size_sex <- lm(CS ~ Sexo, data = datos_SD)

# Allometry (shape ~ size)
modelo_allometry <- procD.lm(coords_mean ~ log(CS),
                             data = datos_SD,
                             iter = 999)

# ==============================/
# 7. PCA visualization----
# ==============================/

pca_plot <- ggplot(scores, aes(Comp1, Comp2, fill = clust)) +
  geom_point(shape = 21, size = 3, color = "black") +
  stat_ellipse(aes(color = clust),
               geom = "polygon",
               alpha = 0.2) +
  scale_fill_viridis_d(option = "turbo") +
  scale_color_viridis_d(option = "turbo") +
  labs(
    title = "PCA - Shape variation",
    x = paste0("PC1 (", var_exp[1], "%)"),
    y = paste0("PC2 (", var_exp[2], "%)")
  ) +
  theme_classic()

print(pca_plot)

# ==============================/
# 8. CVA (shape differentiation)----
# ==============================/

# Use first PCs to reduce noise
pcs <- grep("^Comp", names(scores), value = TRUE)

cva <- lda(clust ~ ., data = scores[, c("clust", pcs[1:10])])

scores_cva <- as.data.frame(predict(cva)$x)
scores_cva$clust <- scores$clust

cva_plot <- ggplot(scores_cva, aes(LD1, LD2, fill = clust)) +
  geom_point(shape = 21, size = 3, color = "black") +
  stat_ellipse(aes(color = clust),
               geom = "polygon",
               alpha = 0.2) +
  scale_fill_viridis_d(option = "turbo") +
  scale_color_viridis_d(option = "turbo") +
  labs(
    title = "CVA - Shape differentiation among clusts",
    x = "LD1",
    y = "LD2"
  ) +
  theme_classic()

print(cva_plot)


cva_plot_sex <- ggplot(scores_cva, aes(LD1, LD2, fill = Sex)) +
  geom_point(shape = 21, size = 3, color = "black") +
  stat_ellipse(aes(color = Sex),
               geom = "polygon",
               alpha = 0.2) +
  scale_fill_viridis_d(option = "turbo") +
  scale_color_viridis_d(option = "turbo") +
  labs(
    title = "CVA - Shape differentiation among clusts",
    x = "LD1",
    y = "LD2"
  ) +
  theme_classic()

print(cva_plot_sex)
# ==============================/
# 9. Save outputs (optional)----
# ==============================/

ggsave("outputs/pca_plot.png", pca_plot, width = 8, height = 6)
ggsave("outputs/cva_plot.png", cva_plot, width = 8, height = 6)

# ==============================/
# End of analysis----
# ==============================/